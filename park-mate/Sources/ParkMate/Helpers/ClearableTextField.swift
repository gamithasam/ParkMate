// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct ClearableTextField: View {
    var title: String
    @Binding var text: String
    var type: String = ""

    var body: some View {
        ZStack(alignment: .trailing) {
            if type == "newPassword" {
                SecureField(title, text: $text)
                #if !SKIP
                    .textContentType(.newPassword)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                #endif
            } else if type == "password" {
                SecureField(title, text: $text)
                #if !SKIP
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                #endif
            } else if type == "email" {
                TextField(title, text: $text)
                #if !SKIP
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                #endif
            } else {
                TextField(title, text: $text)
                #if !SKIP
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                #endif
            }
            
            if !text.isEmpty {
                Button(action: {
                    print("Clear button tapped")
                    text = ""
                }) {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
        }
    }
}
