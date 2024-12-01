//
//  VehiclesList.swift
//  ParkMate Admin
//
//  Created by Gamitha Samarasingha on 2024-12-01.
//

import SwiftUI

struct VehiclesList: View {
    @Binding var vehicles: [String: String]
    
    @Binding var vehiclesIsLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vehicles Currently Inside")
                .font(.headline)
            
            ScrollView {
                if vehiclesIsLoading {
                    ProgressView("Loading vehicles...")
                } else {
                    VStack(spacing: 12) {
                        ForEach(vehicles.sorted(by: { $0.key < $1.key }), id: \.key) { item in
                            VehicleCard(licensePlate: item.key, enteredTime: item.value)
                        }
                    }
                }
            }
        }
    }
}

struct VehicleCard: View {
    let licensePlate: String
    let enteredTime: String
    let currentDate = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(licensePlate)
                .font(.headline)
            Text("Entry Time: \(formatDateString(enteredTime) ?? "Unknown")")
                .font(.subheadline)
                .foregroundColor(.secondary)
            if let parsedDate = parseDate(from: enteredTime) {
                let currentDate = Date()
                if let result = timeDifference(from: parsedDate, to: currentDate) {
                    Text("Duration: \(result)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
    
    private func formatDateString(_ dateString: String) -> String? {
        // Create a DateFormatter for the input format
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        // Parse the input date string to a Date object
        guard let date = inputFormatter.date(from: dateString) else {
            print("Invalid date format")
            return nil
        }

        // Create a DateFormatter for the desired output format
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MM/dd/yyyy h:mma"
        outputFormatter.amSymbol = "AM"
        outputFormatter.pmSymbol = "PM"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")

        // Format the Date object to the desired output string
        let formattedDateString = outputFormatter.string(from: date)
        return formattedDateString
    }
    
    func parseDate(from dateString: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return dateFormatter.date(from: dateString)
    }

    func timeDifference(from date: Date, to currentDate: Date) -> String? {
        let difference = Calendar.current.dateComponents([.hour, .minute], from: date, to: currentDate)
        guard let hours = difference.hour, let minutes = difference.minute else {
            return nil
        }
        
        if hours == 0 {
            return "\(minutes)min"
        } else {
            return "\(hours)h \(minutes)min"
        }
    }
}

//#Preview {
//    VehiclesList()
//}
