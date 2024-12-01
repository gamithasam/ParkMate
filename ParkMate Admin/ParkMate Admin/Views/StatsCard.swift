//
//  StatsCard.swift
//  ParkMate Admin
//
//  Created by Gamitha Samarasingha on 2024-12-01.
//

import SwiftUI

struct StatsCard: View {
    @Binding var parkingSpots: [ParkingSpot]
    @Binding var vehicles: [String: String]
    
    @Binding var parkingSpotsIsLoading: Bool
    @Binding var vehiclesIsLoading: Bool
    
    var body: some View {
        let availableCount = parkingSpots.filter { $0.status == .available }.count
        let reservedCount = parkingSpots.filter { $0.status == .reserved }.count
        let occupiedCount = parkingSpots.filter { $0.status == .occupied }.count
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Overview")
                .font(.headline)
            
            if parkingSpotsIsLoading || vehiclesIsLoading {
                ProgressView()
            } else {
                Group {
                    StatRow(title: "Total Spots", value: "\(parkingSpots.count)")
                    StatRow(title: "Available", value: "\(availableCount)")
                    StatRow(title: "Reserved", value: "\(reservedCount)")
                    StatRow(title: "Occupied", value: "\(occupiedCount)")
                    StatRow(title: "Vehicles Inside", value: "\(vehicles.count)")
                }
            }
        }
        .padding()
        .foregroundColor(.white)
        .background(Color.blue)
        .cornerRadius(12)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
        .font(.subheadline)
    }
}

//#Preview {
//    StatsCard()
//}
