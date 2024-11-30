//
//  HomeView.swift
//  ParkMate Admin
//
//  Created by Gamitha Samarasingha on 2024-12-01.
//

import SwiftUI

struct HomeView: View {
    @Binding var searchText: String
    @Binding var selectedFilter: Int
    
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
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(0..<20) { index in
                        ParkingSpotCard(spotNumber: "A\(index + 1)",
                                      status: index % 3 == 0 ? .available :
                                                index % 3 == 1 ? .reserved : .occupied)
                    }
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

#Preview {
    HomeView(searchText: .constant(""), selectedFilter: .constant(0))
}
