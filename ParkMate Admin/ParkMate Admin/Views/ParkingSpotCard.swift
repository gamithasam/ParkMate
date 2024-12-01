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
    let email: String
    let dateNTime: String
    
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
                    Text("Reserved for: \(email)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Time: \(convertDateString(dateNTime) ?? "Unknown")")
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
    
    func convertDateString(_ dateString: String) -> String? {
        // Define the input date format
        let inputDateFormat = "d MMM yyyy 'at' hh:mm:ss a"
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = inputDateFormat
        inputDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Parse the input date string to a Date object
        guard let date = inputDateFormatter.date(from: dateString) else {
            return nil
        }
        
        // Define the output date format
        let outputDateFormat = "MM/dd/yyyy h:mma"
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = outputDateFormat
        outputDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Convert the Date object to the output date string
        let outputDateString = outputDateFormatter.string(from: date)
        return outputDateString
    }
}

//#Preview {
//    ParkingSpotCard(spotNumber: "A-01", status: .reserved)
//}
