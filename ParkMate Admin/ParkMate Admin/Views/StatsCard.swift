//
//  StatsCard.swift
//  ParkMate Admin
//
//  Created by Gamitha Samarasingha on 2024-12-01.
//

import SwiftUI

struct StatsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overview")
                .font(.headline)
            
            Group {
                StatRow(title: "Total Spots", value: "100")
                StatRow(title: "Available", value: "45")
                StatRow(title: "Reserved", value: "15")
                StatRow(title: "Vehicles Inside", value: "40")
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

#Preview {
    StatsCard()
}
