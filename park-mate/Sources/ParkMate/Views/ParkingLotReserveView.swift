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
        case Available, Occupied, Reserved, Selected
        
        var description: String {
            switch self {
            case .Available: return "Available"
            case .Occupied: return "Occupied"
            case .Reserved: return "Reserved"
            case .Selected: return "Selected"
            }
        }
    }
}

// Sample data

struct ParkingLotReserveView: View {
    let parkingLotId: Int
    @State private var parkingSpots: [ParkingSpot] = []
    @State private var isLoading = true
    var selectedCount: Int {
        parkingSpots.filter { $0.status == .Selected }.count
    }
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Parking Spots...")
                    .padding()
//            } else if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .padding()
            } else {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach($parkingSpots) { $spot in
                        switch (spot.status) {
                        case .Available:
                            Button(action: {
                                print("Tapped spot \(spot.spotId)")
                                spot.status = .Selected
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
                        case .Occupied:
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
                        case .Reserved:
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
                        case .Selected:
                            Button(action: {
                                print("Tapped spot \(spot.spotId)")
                                spot.status = .Available
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
    }
    
    func loadParkingSpots() {
        DatabaseManager.shared.fetchParkingSpots(parkingLotId: parkingLotId) { spots, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
//                    self.errorMessage = "Failed to load parking spots: \(error.localizedDescription)"
                    print("Failed to load parking spots: \(error.localizedDescription)")
                } else if let spots = spots {
                    self.parkingSpots = spots
                    print(parkingSpots)
                }
            }
        }
    }
}
#endif
