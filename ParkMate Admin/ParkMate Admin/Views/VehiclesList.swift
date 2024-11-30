//
//  VehiclesList.swift
//  ParkMate Admin
//
//  Created by Gamitha Samarasingha on 2024-12-01.
//

import SwiftUI

struct VehiclesList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vehicles Currently Inside")
                .font(.headline)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<10) { _ in
                        VehicleCard()
                    }
                }
            }
        }
    }
}

struct VehicleCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("ABC 123")
                .font(.headline)
            Text("Entry Time: 14:30")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Duration: 2h 15m")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    VehiclesList()
}
