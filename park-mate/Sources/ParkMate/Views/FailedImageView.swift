// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct FailedImageView: View {
    var body: some View {
        ZStack {
            Image(systemName: "photo.badge.exclamationmark")
                .foregroundColor(.gray)
                .font(.system(size: 32))
        }
        #if !SKIP
        .background(Color(UIColor.systemGray6))
        #endif
        .disabled(true)
        .cornerRadius(10)
    }
}
