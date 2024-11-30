//
//  ContentView.swift
//  ParkMate Admin
//
//  Created by Gamitha Samarasingha on 2024-12-01.
//

import SwiftUI
import AWSDynamoDB

// Model for a parking spot
struct ParkingSpot: Identifiable {
    let id = UUID()
    let spotId: String
    var status: SpotStatus
    
    enum SpotStatus: String {
        case available, occupied, reserved, selected
    }
}

struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedFilter = 0
    @State var parkingSpots: [ParkingSpot] = []
    let parkingLotId: Int = 1
    
    var body: some View {
        NavigationView {
                // Sidebar
            SidebarView(parkingSpots: $parkingSpots)
                    .frame(width: 300)
                
                // Main Content
            HomeView(searchText: $searchText, selectedFilter: $selectedFilter, parkingSpots: $parkingSpots)
            .navigationTitle("Parking Lot Status")
        }
        .onAppear {
            loadParkingSpots()
        }
    }
    
    func loadParkingSpots() {
        DatabaseManager.shared.fetchParkingSpots(parkingLotId: parkingLotId) { spots, error in
            DispatchQueue.main.async {
//                self.isLoading = false
                if let error = error {
//                    self.alertItem = AlertItem(message: "Failed to load parking spots")
                    print("Failed to load parking spots: \(error.localizedDescription)")
//                    selectedLot = nil
                } else if let spots = spots {
                    self.parkingSpots = spots.sorted { $0.spotId < $1.spotId }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
