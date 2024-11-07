// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct ClearableTextField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .trailing) {
            TextField(title, text: $text)
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
