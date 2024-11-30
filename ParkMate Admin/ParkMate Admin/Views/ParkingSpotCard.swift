//
//  ParkingSpotCard.swift
//  ParkMate Admin
//
//  Created by Gamitha Samarasingha on 2024-12-01.
//

import SwiftUI

struct ParkingSpotCard: View {
    enum SpotStatus {
        case available, reserved, occupied
        
        var color: Color {
            switch self {
            case .available: return .green
            case .reserved: return .orange
            case .occupied: return .red
            }
        }
        
        var text: String {
            switch self {
            case .available: return "Available"
            case .reserved: return "Reserved"
            case .occupied: return "Occupied"
            }
        }
    }
    
    let spotNumber: String
    let status: SpotStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Status Badge
            Text(status.text)
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(status.color)
                .cornerRadius(6)
            
            Text("\(spotNumber)")
                .font(.headline)
            
            if status == .reserved {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reserved for: John Doe")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Time: 20:00 - 22:00")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    ParkingSpotCard(spotNumber: "A-01", status: .reserved)
}
