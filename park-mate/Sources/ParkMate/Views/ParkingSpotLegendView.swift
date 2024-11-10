// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct ParkingSpotLegendView: View {
    var body: some View {
        HStack(spacing: 16) {
            // Available spots
            HStack(spacing: 4) {
                Circle()
                    .fill(.blue)
                    .opacity(0.15)
                    .frame(width: 12, height: 12)
                Text("Available")
                    .font(.caption)
            }
            
            // Occupied spots
            HStack(spacing: 4) {
                Circle()
                    .fill(.gray)
                    .frame(width: 12, height: 12)
                Text("Occupied")
                    .font(.caption)
            }
            
            // Reserved spots
            HStack(spacing: 4) {
                Circle()
                    .fill(.red)
                    .frame(width: 12, height: 12)
                Text("Reserved")
                    .font(.caption)
            }
            
            // Selected spots
            HStack(spacing: 4) {
                Circle()
                    .fill(.blue)
                    .frame(width: 12, height: 12)
                Text("Selected")
                    .font(.caption)
            }
        }
        .padding(.bottom)
    }
}
