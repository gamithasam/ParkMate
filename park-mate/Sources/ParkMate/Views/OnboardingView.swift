// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI

struct OnboardingView: View {
    @State private var currentTab = 0
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var signInError: String?
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentTab) {
                
                // Welcome Screen
                VStack(spacing: 20) {
                    Image("LogoFull")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)
                    
                    Text("Welcome to ParkMate!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("We’re excited to have you with us. Start exploring easy parking.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        currentTab = 1  // Move to the Sign-In screen
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .padding(.top, 30)
                }
                .tag(0)
                
                // Sign-In Screen
                VStack(spacing: 20) {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                    
                    Text("Sign In")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Please sign in to continue exploring our features.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Sign In Form (Placeholder for simplicity)
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled(true)
                            .textContentType(.username)
                            .autocapitalization(.none)
                            .padding(.horizontal)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        // Handle sign-in logic here
                        print("User signed in!")
                        print(email)
                        print(password)
                        #if !SKIP
                        signIn(email: email, password: password)
                        #endif
                    }) {
                        Text("Sign In")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Navigation link to sign-up screen
                    NavigationLink(destination: SignUpView()) {
                        Text("Don't have an account? Sign Up")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .padding(.top, 10)
                    }
                }
                .tag(1)
                
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
//            .navigationTitle("")
        }
    }
    #if !SKIP
    func signIn(email: String, password: String) {
        // Clear any previous error
        signInError = nil
        
        // Basic validation
        guard !email.isEmpty else {
            signInError = "Please enter your email"
            print(signInError! ?? "")
            return
        }
        
        guard !password.isEmpty else {
            signInError = "Please enter your password"
            print(signInError! ?? "")
            return
        }

        // Fetch user from DynamoDB based on email
        DatabaseManager.shared.fetchUser(email: email) { user, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.signInError = "Error fetching user: \(error.localizedDescription)"
                    print(self.signInError! ?? "")
                }
                return
            }

            guard let user = user else {
                DispatchQueue.main.async {
                    self.signInError = "No account found with this email."
                    print(self.signInError! ?? "")
                }
                return
            }

            // Retrieve salt and hashed password
            guard let saltData = Data(base64Encoded: user.salt!),
                  let storedHashData = Data(base64Encoded: user.password!) else {
                DispatchQueue.main.async {
                    self.signInError = "Invalid stored credentials."
                    print(self.signInError! ?? "")
                }
                return
            }

            // Hash the entered password with the retrieved salt
            guard let enteredHash = PasswordHelper.hashPassword(password, salt: saltData) else {
                DispatchQueue.main.async {
                    self.signInError = "Error processing password."
                    print(self.signInError! ?? "")
                }
                return
            }

            // Compare the hashes
            if enteredHash == storedHashData {
                DispatchQueue.main.async {
                    // Save user session
                    UserDefaults.standard.set(user.email, forKey: "userEmail")
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    
                    // Navigate to the main app view
                    print("Successfully signed in with email: \(user.email)")
                    // TODO: Add navigation to main app view
                }
            } else {
                DispatchQueue.main.async {
                    self.signInError = "Incorrect password."
                    print(self.signInError! ?? "")
                }
            }
        }
    }
    #endif
}
#endif
