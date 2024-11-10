// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
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
                #if !SKIP
                .listRowInsets(EdgeInsets())
                #endif
                
                Section {
                    #if !SKIP
                    NavigationLink(destination: PersonalInfoView()) {
                        Text("Personal information")
                    }
                    NavigationLink(destination: VehiclesView()) {
                        Text("Vehicles")
                    }
                    NavigationLink(destination: SignInNSecurityView()) {
                        Text("Sign-In & Security")
                    }
                    #endif
                }
                
                #if !SKIP
                Section {
                    Button(role: .destructive) {
                        logout()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Logout")
                            Spacer()
                        }
                    }
                }
                #endif
            }
            .navigationTitle("Profile")
//            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    #if !SKIP
    private func logout() {
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            UserDefaults.standard.synchronize()
        }
    }
    #endif
}

