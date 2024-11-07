// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI
import AWSDynamoDB

struct PersonalInfoView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var birthday: Date = Date()
    @State private var alertItem: AlertItem?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            HStack {
                Text("First Name")
                ClearableTextField(title: "required", text: $firstName)
            }
            HStack {
                Text("Last Name")
                ClearableTextField(title: "required", text: $lastName)
            }
            HStack {
                DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
            }
        }
        .navigationTitle("Personal Information")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    // Add your save action here
                    saveData()
                    dismiss()
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
        guard let email = UserDefaults.standard.string(forKey: "userEmail") else {
            print("Email not found in UserDefaults")
            self.alertItem = AlertItem(message: "An error occurred. Please try again.")
            return
        }
        
        // Configure AWS DynamoDB
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        // Create the user key
        let userKey = User()
        userKey!.email = email
        
        // Fetch the user data
        dynamoDBObjectMapper.load(User.self, hashKey: email, rangeKey: nil).continueWith { (task: AWSTask<AnyObject>!) -> Any? in
            if let error = task.error {
                print("Error fetching user details: \(error.localizedDescription)")
                self.alertItem = AlertItem(message: "An error occurred. Please try again.")
            } else if let user = task.result as? User {
                DispatchQueue.main.async {
                    self.firstName = user.firstName ?? ""
                    self.lastName = user.lastName ?? ""
                    // Convert birthday string to Date
                    if let birthdayString = user.birthday, let date = self.stringToDate(birthdayString) {
                        self.birthday = date
                    }
                }
            }
            return nil
        }
    }
    
    func stringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.date(from: dateString)
    }
    
    func saveData() {
        // Get the user's email from UserDefaults
        guard let email = UserDefaults.standard.string(forKey: "userEmail") else {
            print("Email not found in UserDefaults")
            self.alertItem = AlertItem(message: "An error occurred. Please try again.")
            return
        }
        
        // Create a User object with the updated information
        let user = User()
        user!.email = email
        user!.firstName = firstName
        user!.lastName = lastName
        
        // Convert Date to string for storage
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        user!.birthday = dateFormatter.string(from: birthday)
        
        // Get the DynamoDB object mapper
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        // Save the user data
        dynamoDBObjectMapper.save(user!, completionHandler: { (error) in
            if let error = error {
                print("Error saving user details: \(error.localizedDescription)")
                self.alertItem = AlertItem(message: "An error occurred. Please try again.")
            } else {
                print("Successfully saved user details")
                dismiss()
            }
        })
    }
}
#endif
