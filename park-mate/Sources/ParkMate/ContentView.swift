// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

public struct ContentView: View {
    @State private var selection: Tab = .home

    enum Tab: String, Hashable {
        case home
        case reservations
        case profile
    }
    
    public init() {
    }

    public var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)
            ReservationsView()
                .tabItem {
                    Label("Reservations", systemImage: "text.page")
                }
                .tag(Tab.reservations)
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(Tab.profile)
        }
    }
}
