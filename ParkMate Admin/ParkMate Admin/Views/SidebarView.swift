//
//  SidebarView.swift
//  ParkMate Admin
//
//  Created by Gamitha Samarasingha on 2024-12-01.
//

import SwiftUI

struct SidebarView: View {
    @Binding var parkingSpots: [ParkingSpot]
    
    var body: some View {
        VStack(spacing: 16) {
            // Statistics Card
            StatsCard(parkingSpots: $parkingSpots)
            
            // Vehicles List
            VehiclesList()
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

//#Preview {
//    SidebarView()
//}
