// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI
import AWSDynamoDB

struct SignInNSecurityView: View {
    @State private var email: String = ""
    @State private var currentPass: String = ""
    @State private var newPass: String = ""
    @State private var confirmPass: String = ""
    @State private var alertItem: AlertItem?
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPasswordValid: Bool = true
    @State private var doPasswordsMatch: Bool = true
    
    var body: some View {
        Form {
            HStack {
                Text("Email")
                ClearableTextField(title: "required", text: $email, type: "email")
            }
            HStack {
                Text("Current Password")
                ClearableTextField(title: "required", text: $currentPass, type: "password")
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("New Password")
                    ClearableTextField(title: "required", text: $newPass, type: "newPassword")
                }
                if !isPasswordValid {
                    Text("Password must be at least 8 characters")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Confirm Password")
                    ClearableTextField(title: "required", text: $confirmPass, type: "newPassword")
                }
                if !doPasswordsMatch {
                    Text("Passwords do not match")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Sign-In & Security")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    validateAndSave()
                }
            }
        }
        .onAppear {
            fetchUserDetails()
        }
        .alert(item: $alertItem) { alert in
            Alert(
                title: Text("Error"),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func fetchUserDetails() {
        // Get the user's email from UserDefaults
        self.email = UserDefaults.standard.string(forKey: "userEmail") ?? {
            print("Email not found in UserDefaults")
            self.alertItem = AlertItem(message: "An error occurred. Please try again.")
            return ""
        }()
    }
    
    func validateAndSave() {
        // Reset validation states
        isPasswordValid = true
        doPasswordsMatch = true
        
        // Validate password
        if newPass.count < 8 {
            isPasswordValid = false
        }
        
        // Check if passwords match
        if newPass != confirmPass {
            doPasswordsMatch = false
        }
        
        if isPasswordValid && doPasswordsMatch {
            saveData()
        }
    }
    
    func saveData() {
        // Get the user's email from UserDefaults
        guard let email = UserDefaults.standard.string(forKey: "userEmail") else {
            print("Email not found in UserDefaults")
            self.alertItem = AlertItem(message: "An error occurred. Please try again.")
            return
        }
        
        // Fetch user from DynamoDB based on email
        DatabaseManager.shared.fetchUser(email: email) { user, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error fetching user: \(error.localizedDescription)")
                    self.alertItem = AlertItem(message: "An error occured. Please try again later.")
                }
                return
            }

            guard let user = user else {
                DispatchQueue.main.async {
                    self.alertItem = AlertItem(message: "An error occured. Please try again later.")
                    // Clear text fields
                    self.email = ""
                    self.currentPass = ""
                    self.newPass = ""
                    self.confirmPass = ""
                }
                return
            }

            // Retrieve salt and hashed password
            guard let saltData = Data(base64Encoded: user.salt!),
                  let storedHashData = Data(base64Encoded: user.password!) else {
                DispatchQueue.main.async {
                    self.alertItem = AlertItem(message: "Invalid stored credentials.")
                    // Clear text fields
                    self.email = ""
                    self.currentPass = ""
                    self.newPass = ""
                    self.confirmPass = ""
                }
                return
            }

            // Hash the entered password with the retrieved salt
            guard let enteredHash = PasswordHelper.hashPassword(currentPass, salt: saltData) else {
                DispatchQueue.main.async {
                    self.alertItem = AlertItem(message: "Error processing password")
                    // Clear text fields
                    self.email = ""
                    self.currentPass = ""
                    self.newPass = ""
                    self.confirmPass = ""
                }
                return
            }

            // Compare the hashes
            guard enteredHash == storedHashData else {
                DispatchQueue.main.async {
                    self.alertItem = AlertItem(message: "Incorrect password.")
                    self.email = ""
                    self.currentPass = ""
                    self.newPass = ""
                    self.confirmPass = ""
                }
                return
            }
            
            guard let newSalt = PasswordHelper.generateSalt(),
                  let newPasswordHash = PasswordHelper.hashPassword(newPass, salt: newSalt) else {
                print("Failed to generate salt or hash password")
                self.alertItem = AlertItem(message: "An error occurred. Please try again.")
                return
            }
            
            user.password = newPasswordHash.base64EncodedString()
            user.salt = newSalt.base64EncodedString()
            
            // Save the user data
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
            dynamoDBObjectMapper.save(user, completionHandler: { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error saving user details: \(error.localizedDescription)")
                        self.alertItem = AlertItem(message: "An error occurred. Please try again.")
                    } else {
                        print("Successfully saved user details")
                        dismiss()
                    }
                }
            })
        }
    }
}
#endif
