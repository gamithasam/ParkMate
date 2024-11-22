// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI
import LocalAuthentication

struct MockPaymentSheet: View {
    @Environment(\.presentationMode) var presentationMode
    let title: String
    let price: Double
    var onPaymentCompleted: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
            }
            .padding([.horizontal, .top])
            
            Spacer()
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(String(format: "Rs. %.2f", price))
                    .font(.system(size: 42, weight: .bold))
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "faceid")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                
                Text("Confirm with Face ID")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                authenticateUser()
//                presentationMode.wrappedValue.dismiss()
//                onPaymentCompleted()
            }) {
                Text("Pay")
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
    }
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?

        // Check if biometrics or passcode authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Authenticate to proceed with payment"

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Authentication successful
                        presentationMode.wrappedValue.dismiss()
                        onPaymentCompleted()
                    } else {
                        // Authentication failed
                        print("Auth Failed")
                        // Handle the error (e.g., show an alert)
                    }
                }
            }
        } else {
            // Authentication not available
            print("Auth N/A")
            // Handle the error (e.g., show an alert)
        }
    }
}
#endif
