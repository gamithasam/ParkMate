// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI

// Model for a parking spot
struct ParkingSpot: Identifiable {
    let id = UUID()
    let spotId: String
    var status: SpotStatus
    
    enum SpotStatus: String, CustomStringConvertible {
        case available, occupied, reserved, selected
        
        var description: String {
            switch self {
            case .available: return "Available"
            case .occupied: return "Occupied"
            case .reserved: return "Reserved"
            case .selected: return "Selected"
            }
        }
    }
}

// Sample data

struct ParkingLotReserveView: View {
    let parkingLotId: Int
    @State private var parkingSpots: [ParkingSpot] = []
    @State private var isLoading = true
    @State private var alertItem: AlertItem?
    @Environment(\.dismiss) private var dismiss
    var selectedCount: Int {
        parkingSpots.filter { $0.status == .selected }.count
    }
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Parking Spots...")
                    .padding()
            } else if alertItem == nil {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach($parkingSpots) { $spot in
                        switch (spot.status) {
                        case .available:
                            Button(action: {
                                print("Tapped spot \(spot.spotId)")
                                spot.status = .selected
                            }) {
                                VStack(spacing: 2) {
                                    Text(spot.spotId)
                                        .font(.body)
                                    Text(spot.status.description)
                                        .font(.caption)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 12)
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                            .fixedSize(horizontal: false, vertical: true)
                        case .occupied:
                            Button(action: {
                                print("Tapped spot \(spot.spotId)")
                            }) {
                                VStack(spacing: 2) {
                                    Text(spot.spotId)
                                        .font(.body)
                                    Text(spot.status.description)
                                        .font(.caption)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 12)
                            }
                            .buttonStyle(.bordered)
                            .fixedSize(horizontal: false, vertical: true)
                        case .reserved:
                            Button(action: {
                                print("Tapped spot \(spot.spotId)")
                            }) {
                                VStack(spacing: 2) {
                                    Text(spot.spotId)
                                        .font(.body)
                                    Text(spot.status.description)
                                        .font(.caption)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 12)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .fixedSize(horizontal: false, vertical: true)
                        case .selected:
                            Button(action: {
                                print("Tapped spot \(spot.spotId)")
                                spot.status = .available
                            }) {
                                VStack(spacing: 2) {
                                    Text(spot.spotId)
                                        .font(.body)
                                    Text(spot.status.description)
                                        .font(.caption)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 12)
                            }
                            .buttonStyle(.borderedProminent)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
            
            ParkingSpotLegendView()
            
            Button(action: {
                print("Reserved")
            }) {
                VStack(alignment: .center) {
                    Text("Reserve")
                    Text("(Rs.800)")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding()
            .disabled(selectedCount == 0)
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            loadParkingSpots()
        }
        .alert(item: $alertItem) { alert in
            Alert(
                title: Text("Error"),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func loadParkingSpots() {
        DatabaseManager.shared.fetchParkingSpots(parkingLotId: parkingLotId) { spots, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.alertItem = AlertItem(message: "Failed to load parking spots")
                    print("Failed to load parking spots: \(error.localizedDescription)")
                    dismiss()
                } else if let spots = spots {
                    self.parkingSpots = spots
                }
            }
        }
    }
}
#endif
