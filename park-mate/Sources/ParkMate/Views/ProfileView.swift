// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    VStack(spacing: 15) {
                        ZStack {
                            Rectangle()
                                .frame(width: 55, height: 55)
                                .foregroundColor(.gray)
                                .cornerRadius(12)
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.white)
                        }
                        
                        Text("Profile")
                            .font(.headline)
                        
                        Text("Manage your account details, vehicles, payment methods, and parking preferences.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 25)
                    .padding(.horizontal, 20)
                }
                
                List {
                    NavigationLink(destination: PersonalInfoView()) {
                        Text("Personal information")
                    }
                    NavigationLink(destination: destinationView) {
                        Text("Vehicles")
                    }
                    NavigationLink(destination: destinationView) {
                        Text("Sign-In & Security")
                    }
                }
            }
            .navigationTitle("Profile")
//            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private func destinationView() -> some View {
        Text("This is a placeholder.") // Placeholder view
    }
}

