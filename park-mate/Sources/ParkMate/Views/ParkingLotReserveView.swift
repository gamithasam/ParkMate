// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI
import AWSDynamoDB

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

struct ParkingLotReserveView: View {
    let parkingLotId: Int
    let selectedDateNTime: Date
    let hours: Int
    let vehicle: String
    let price: Double
    
    @State private var parkingSpots: [ParkingSpot] = []
    @State private var isLoading = true
    @State private var isReserving = false
    @State private var alertItem: AlertItem?
    var selectedCount: Int {
        parkingSpots.filter { $0.status == .selected }.count
    }
    
    @Binding var selectedLot: ParkingLot?
    
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
                            .fixedSize(horizontal: true, vertical: true)
                        case .occupied:
                            Button(action: {
                                print("Tapped spot \(spot.spotId)")
                            }) {
//                                Image("CarIcon")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
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
                            .foregroundColor(.black)
                            .fixedSize(horizontal: true, vertical: true)
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
                            .fixedSize(horizontal: true, vertical: true)
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
                            .fixedSize(horizontal: true, vertical: true)
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
            
            ParkingSpotLegendView()
            
            Button(action: {
                reserveSpot()
            }) {
                if isReserving {
                    ProgressView()
                } else {
                    VStack(alignment: .center) {
                        Text("Reserve")
                        Text(String(format: "(Rs. %.2f)", price))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding()
            .disabled(selectedCount == 0 || isReserving)
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
                    selectedLot = nil
                } else if let spots = spots {
                    self.parkingSpots = spots.sorted { $0.spotId < $1.spotId }
                }
            }
        }
    }
    
    func reserveSpot() {
        let selectedSpots = parkingSpots.filter { $0.status == .selected }
        let spotIdsToReserve = selectedSpots.map { $0.spotId }
        
        guard !spotIdsToReserve.isEmpty else { return }
        
        isReserving = true
        
        // Update ParkingSpots Table
        DatabaseManager.shared.reserveParkingSpots(parkingLotId: parkingLotId, spotIds: spotIdsToReserve) { error in
            DispatchQueue.main.async {
                self.isReserving = false
                if let error = error {
                    self.alertItem = AlertItem(message: "Failed to reserve parking spots")
                    print("Failed to reserve spots: \(error.localizedDescription)")
                } else {
                    // After successfully reserving spots, add reservations
                    self.addReservations(for: selectedSpots)
                    selectedLot = nil
                }
            }
        }
    }
    
    func addReservations(for spots: [ParkingSpot]) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let dispatchGroup = DispatchGroup()
        
        for spot in spots {
            dispatchGroup.enter()
            
            let reservation = Reservation()
            reservation!.email = UserDefaults.standard.string(forKey: "userEmail")
            reservation!.parkingLotId = NSNumber(value: self.parkingLotId)
            reservation!.spotId = spot.spotId
            reservation!.dateNTime = DateFormatter.localizedString(from: self.selectedDateNTime, dateStyle: .medium, timeStyle: .medium)
            reservation!.vehicle = self.vehicle
            reservation!.hours = NSNumber(value: self.hours)
            reservation!.price = NSNumber(value: self.price)
            
            dynamoDBObjectMapper.save(reservation!) { error in
                if let error = error {
                    print("Failed to add reservation for spot \(spot.spotId): \(error.localizedDescription)")
                    self.alertItem = AlertItem(message: "Failed to add reservation")
                }
                dispatchGroup.leave()
            }
        }
    }
}
#endif
