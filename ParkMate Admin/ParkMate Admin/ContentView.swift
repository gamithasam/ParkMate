//
//  ContentView.swift
//  ParkMate Admin
//
//  Created by Gamitha Samarasingha on 2024-12-01.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedFilter = 0
    
    var body: some View {
        NavigationView {
                // Sidebar
                SidebarView()
                    .frame(width: 300)
                
                // Main Content
                HomeView(searchText: $searchText, selectedFilter: $selectedFilter)
            .navigationTitle("Parking Lot Status")
        }
    }
}

#Preview {
    ContentView()
}
