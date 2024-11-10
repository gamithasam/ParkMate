// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

struct OnboardingView: View {
    @State private var currentTab = 0
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var alertItem: AlertItem?
    @State private var isLoading = false
    @State private var isLoggedIn = false
    @AppStorage("userVehicles") var userVehiclesData: Data = Data()

    // Validation states
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    
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
                        
                        if !isEmailValid {
                            Text("Please enter a valid email address")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .padding(.horizontal)
                        
                        if !isPasswordValid {
                            Text("Please enter your password")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        // Handle sign-in logic here
                        isLoading = true
                        print("User signed in!")
                        print(email)
                        print(password)
                        signIn(email: email, password: password)
                    }) {
                        if isLoading {
                           ProgressView()
                        } else {
                            Text("Sign In")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
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
        }
        .fullScreenCover(isPresented: $isLoggedIn) {
            ContentView()
        }
    }
    #if !SKIP
    func signIn(email: String, password: String) {
        // Clear any previous error
        isEmailValid = true
        isPasswordValid = true
        
        // Email validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isEmailValid = emailPredicate.evaluate(with: email)
        
        // Password validation
        guard !password.isEmpty else {
            isPasswordValid = false
            isLoading = false
            return
        }

        // Fetch user from DynamoDB based on email
        DatabaseManager.shared.fetchUser(email: email) { user, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error fetching user: \(error.localizedDescription)")
                    self.alertItem = AlertItem(message: "An error occured. Please try again later.")
                }
                isLoading = false
                return
            }

            guard let user = user else {
                DispatchQueue.main.async {
                    self.alertItem = AlertItem(message: "No account found with this email.")
                    // Clear text fields
                    self.email = ""
                    self.password = ""
                }
                isLoading = false
                return
            }

            // Retrieve salt and hashed password
            guard let saltData = Data(base64Encoded: user.salt!),
                  let storedHashData = Data(base64Encoded: user.password!) else {
                DispatchQueue.main.async {
                    self.alertItem = AlertItem(message: "Invalid stored credentials.")
                    // Clear text fields
                    self.email = ""
                    self.password = ""
                }
                isLoading = false
                return
            }

            // Hash the entered password with the retrieved salt
            guard let enteredHash = PasswordHelper.hashPassword(password, salt: saltData) else {
                DispatchQueue.main.async {
                    self.alertItem = AlertItem(message: "Error processing password")
                    // Clear text fields
                    self.email = ""
                    self.password = ""
                }
                isLoading = false
                return
            }

            // Compare the hashes
            if enteredHash == storedHashData {
                DispatchQueue.main.async {
                    // Save user session
                    UserDefaults.standard.set(user.email, forKey: "userEmail")
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    self.isLoggedIn = true
                    print("Successfully signed in with email: \(user.email!)")
                    // TODO: Add navigation to main app view
                }
            } else {
                DispatchQueue.main.async {
                    self.alertItem = AlertItem(message: "Incorrect password.")

                    // Clear text fields
                    self.email = ""
                    self.password = ""
                }
            }
        }
        
        // Fetch vehicles from DynamoDB based on email
        DatabaseManager.shared.fetchVehicles(email: email) { vehicles, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error fetching vehicle: \(error.localizedDescription)")
                    self.alertItem = AlertItem(message: "An error occured. Please log in again.")
                    logout()
                }
                isLoading = false
                return
            }
            
            // Encode vehicles to Data
            if let vehicles = vehicles {
                do {
                    let encodedData = try JSONEncoder().encode(vehicles)
                    DispatchQueue.main.async {
                        userVehiclesData = encodedData
                    }
                } catch {
                    DispatchQueue.main.async {
                        print("Error encoding vehicles: \(error.localizedDescription)")
                        self.alertItem = AlertItem(message: "An error occured. Please log in again.")
                        logout()
                    }
                }
            }
            
            isLoading = false
        }
        isLoading = false
        
    }
    #endif
}
#endif
