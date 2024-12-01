//
//  SidebarView.swift
//  ParkMate Admin
//
//  Created by Gamitha Samarasingha on 2024-12-01.
//

import SwiftUI

struct SidebarView: View {
    @Binding var parkingSpots: [ParkingSpot]
    @State private var vehicles: [String: String] = [:]
    
    var body: some View {
        VStack(spacing: 16) {
            // Statistics Card
            StatsCard(parkingSpots: $parkingSpots, vehicles: $vehicles)
            
            // Vehicles List
            VehiclesList(vehicles: $vehicles)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
        .onAppear {
            fetchVehicles()
        }
    }
    
    private func fetchVehicles() {
        DatabaseManager.shared.fetchInsideVehicles(parkingLotId: 1) { (vehiclesData, error) in
            if let error = error {
                print("Error fetching vehicles: \(error)")
            } else if let vehiclesData = vehiclesData {
                // Update the state variable on the main thread
                DispatchQueue.main.async {
                    self.vehicles = vehiclesData
                }
            } else {
                print("No vehicles found.")
            }
        }
    }
}

//#Preview {
//    SidebarView()
//}
