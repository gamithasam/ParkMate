// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI
import AWSDynamoDB

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

struct SignUpView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var birthday = Date()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var alertItem: AlertItem?
    @State private var isLoading = false
    
    // Validation states
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    @State private var doPasswordsMatch = true
    @State private var isBirthdayValid = true
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.orange)
            
            Text("Create an Account")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Sign up to start your journey with us!")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Sign-Up Form (Placeholder for simplicity)
            VStack(spacing: 15) {
                TextField("First Name", text: $firstName)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(true)
                    .textContentType(.givenName)
                    .padding(.horizontal)
                
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(true)
                    .textContentType(.familyName)
                    .padding(.horizontal)
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled(true)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal)
                
                if !isEmailValid {
                    Text("Please enter a valid email address")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal)
                
                if !isPasswordValid {
                    Text("Password must be at least 8 characters")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal)
                
                if !doPasswordsMatch {
                    Text("Passwords do not match")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                DatePicker("Birthday", selection: $birthday, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding(.horizontal)
                
                if !isBirthdayValid {
                    Text("You must be at least 17 years old to use ParkMate")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            Button(action: {
                isLoading = true
                validateAndSubmit()
            }) {
                if isLoading {
                   ProgressView()
                } else {
                    Text("Create Account")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .padding(.top, 20)
            .disabled(isLoading)
            .alert(item: $alertItem) { alert in
                Alert(
                    title: Text("Error"),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK")) {
                        isLoading = false
                    }
                )
            }
        }
        .padding()
    }
    
    private func validateAndSubmit() {
        // Reset validation states
        isEmailValid = true
        isPasswordValid = true
        doPasswordsMatch = true
        isBirthdayValid = true
        
        // Validate email
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isEmailValid = emailPredicate.evaluate(with: email)
        
        // Validate password
        if password.count < 8 {
            isPasswordValid = false
        }
        
        // Check if passwords match
        if password != confirmPassword {
            doPasswordsMatch = false
        }
        
        // Validate birthday
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        let age = ageComponents.year ?? 0
        if age < 17 {
            isBirthdayValid = false
        }
        
        isLoading = false
        
        // Submit
        if isEmailValid && isPasswordValid && doPasswordsMatch && isBirthdayValid {
            submit()
        }
    }
    
    func checkUserExists(email: String, completion: @escaping (Bool) -> Void) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        // Create a query expression
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#email = :emailValue"
        queryExpression.expressionAttributeNames = ["#email": "email"]
        queryExpression.expressionAttributeValues = [":emailValue": email]

        dynamoDBObjectMapper.query(User.self, expression: queryExpression) { (response, error) in
            if let error = error {
                print("Error checking user existence: \(error)")
                completion(false)
                return
            }
            
            // If we find any items, the user exists
            let userExists = (response?.items.count ?? 0) > 0
            completion(userExists)
        }
    }
    
    private func submit() {
        checkUserExists(email: email) { userExists in
            if userExists {
                DispatchQueue.main.async {
                    self.alertItem = AlertItem(message: "A user with this email already exists")
                }
                return
            }
            
            guard let salt = PasswordHelper.generateSalt(),
                  let passwordHash = PasswordHelper.hashPassword(password, salt: salt) else {
                print("Failed to generate salt or hash password")
                return
            }
        
            let user = User()
            user?.email = self.email
            user?.firstName = self.firstName
            user?.lastName = self.lastName
            user?.lastName = self.lastName
            user?.birthday = DateFormatter.localizedString(from: self.birthday, dateStyle: .medium, timeStyle: .none)
            user?.password = passwordHash.base64EncodedString()
            user?.salt = salt.base64EncodedString()
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
            dynamoDBObjectMapper.save(user!) { error in
                if let error = error {
                    print("Error saving to DynamoDB: \(error)")
                    self.alertItem = AlertItem(message: "An error occured while saving this account. Please try again.")
                } else {
                    print("User saved successfully.")
                }
            }
        }
    }
}
#endif
