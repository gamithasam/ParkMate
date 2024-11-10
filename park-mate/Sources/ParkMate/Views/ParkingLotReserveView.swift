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

    enum SpotStatus: CustomStringConvertible {
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
    @State private var parkingSpots = [
        ParkingSpot(spotId: "A-01", status: .Selected),
        ParkingSpot(spotId: "A-02", status: .Occupied),
        ParkingSpot(spotId: "A-03", status: .Reserved),
        ParkingSpot(spotId: "A-04", status: .Available),
        ParkingSpot(spotId: "A-05", status: .Occupied),
        ParkingSpot(spotId: "A-06", status: .Available),
        ParkingSpot(spotId: "A-07", status: .Reserved),
        ParkingSpot(spotId: "A-08", status: .Available),
        ParkingSpot(spotId: "A-09", status: .Occupied)
    ]
    var selectedCount: Int {
        parkingSpots.filter { $0.status == .Selected }.count
    }
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        VStack {
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
    }
}
#endif
