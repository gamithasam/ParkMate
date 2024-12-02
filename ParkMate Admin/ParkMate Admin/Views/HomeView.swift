//
//  HomeView.swift
//  ParkMate Admin
//
//  Created by Gamitha Samarasingha on 2024-12-01.
//

import SwiftUI
import AWSDynamoDB

struct HomeView: View {
    @StateObject private var viewModel = ReservationsViewModel()
    let parkingLotId: Int = 1
    
    @Binding var searchText: String
    @Binding var selectedFilter: Int
    @Binding var parkingSpots: [ParkingSpot]
    @Binding var isLoading: Bool
    
    private let columns = [
        GridItem(.adaptive(minimum: 200), spacing: 16)
    ]
    
    private var filteredSpots: [ParkingSpot] {
        switch selectedFilter {
        case 1:
            return parkingSpots.filter { $0.status == .available }
        case 2:
            return parkingSpots.filter { $0.status == .reserved }
        default:
            return parkingSpots
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Filter Segments
            Picker("Filter", selection: $selectedFilter) {
                Text("All Spots").tag(0)
                Text("Available").tag(1)
                Text("Reserved").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Parking Grid
            ScrollView {
                if isLoading {
                    ProgressView("Loading Parking Spots...")
                        .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredSpots) { spot in
                            let email = viewModel.reservationsDict[spot.spotId]?.email ?? "N/A"
                            let dateNTime = viewModel.reservationsDict[spot.spotId]?.dateNTime ?? "N/A"

                            ParkingSpotCard(
                                spotNumber: spot.spotId,
                                status: spot.status == .available ? .available : .occupied,
                                email: email,
                                dateNTime: dateNTime
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            // Fetch reservations when the view appears
            viewModel.fetchReservations(parkingLotId: parkingLotId)
        }
        
    }

}

//#Preview {
//    HomeView(
//        searchText: .constant(""),
//        selectedFilter: .constant(0),
//        parkingSpots: .constant([]),
//        isLoading: .constant(false)
//    )
//}
