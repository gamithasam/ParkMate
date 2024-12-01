//
//  HomeView.swift
//  ParkMate Admin
//
//  Created by Gamitha Samarasingha on 2024-12-01.
//

import SwiftUI
import AWSDynamoDB

struct HomeView: View {
    @Binding var searchText: String
    @Binding var selectedFilter: Int
    @Binding var parkingSpots: [ParkingSpot]
    @Binding var isLoading: Bool
    
    private let columns = [
        GridItem(.adaptive(minimum: 200), spacing: 16)
    ]
    
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
                        ForEach($parkingSpots) { $spot in
                            ParkingSpotCard(spotNumber: spot.spotId, status: spot.status == .available ? .available :
                                                spot.status == .reserved ? .reserved : .occupied)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        
    }

}

//#Preview {
//    HomeView(searchText: .constant(""), selectedFilter: .constant(0))
//}
