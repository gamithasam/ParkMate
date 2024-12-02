// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI
import AWSDynamoDB
import AWSIoT

// Model for a parking spot
struct ParkingSpot: Identifiable {
    let id = UUID()
    let spotId: String
    var status: SpotStatus
    
    enum SpotStatus: String, CustomStringConvertible {
        case available, occupied, selected
        
        var description: String {
            switch self {
            case .available: return "Available"
            case .occupied: return "Occupied"
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
    
    @StateObject private var viewModel = AllReservationsViewModel()
    
    @State private var parkingSpots: [ParkingSpot] = []
    @State private var isLoading = true
    @State private var isReserving = false
    @State private var alertItem: AlertItem?
    @State private var showMockPaymentSheet = false
    var selectedCount: Int {
        parkingSpots.filter { $0.status == .selected }.count
    }
    
    @Binding var selectedLot: ParkingLot?
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    // Initialize AWSIoTManager
    let awsIoTManager = IoTManager()
    
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
                            if let reservationDate = viewModel.reservationsDict[spot.spotId]?.dateNTime {
                                // If this spot has a reservation this closure runs
                                // Check whether the reservation is in the specified time
                                if isDateWithinRange(selectedDate: self.selectedDateNTime, selectedHours: self.hours, reservationDate: reservationDate, reservationHours: viewModel.reservationsDict[spot.spotId]?.hours ?? 1, spot: String(spot.spotId)) {
                                    // If this closure runs, the spot is reserved
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
                                } else {
                                    // If this closure runs, the spot is avaialable at the selected time (the reservation is at another time)
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
                                }
                            } else {
                                // There's no reservation for this spot
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
                            }
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
                showMockPaymentSheet = true
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
            viewModel.fetchAllReservations(parkingLotId: parkingLotId)
        }
        .alert(item: $alertItem) { alert in
            Alert(
                title: Text("Error"),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showMockPaymentSheet) {
            MockPaymentSheet(
                title: "Reserve",
                price: self.price,
                onPaymentCompleted: {
                    reserveSpot()
                    print("Payed")
                }
            )
            .presentationDetents([.medium])
        }
    }
    
    func isDateWithinRange(selectedDate: Date, selectedHours: Int, reservationDate: String, reservationHours: NSNumber, spot: String) -> Bool {
        // Define the date formatter to match the format of your string date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy 'at' h:mm:ss a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Parse the string date into a Date object
        guard let parsedReservationDate = dateFormatter.date(from: reservationDate) else {
            // If parsing fails, return false or handle the error accordingly
            return false
        }
        
        // Calculate the reservation end date by adding the specified number of hours
        guard let reservationEndDate = Calendar.current.date(byAdding: .hour, value: reservationHours.intValue, to: parsedReservationDate) else {
            // If date calculation fails, return false or handle the error accordingly
            return false
        }
        
        // Calculate the selected end date by adding the specified number of hours
        guard let selectedEndDate = Calendar.current.date(byAdding: .hour, value: selectedHours, to: selectedDate) else {
            // If date calculation fails, return false or handle the error accordingly
            return false
        }
        
        // Calculate the status
        let beginningStatus = (selectedDate <= reservationEndDate && selectedDate >= parsedReservationDate)
        let endStatus = (selectedEndDate <= reservationEndDate && selectedEndDate >= parsedReservationDate)
        let status = beginningStatus || endStatus

        print("Spot: \(spot) | SelectedDate: \(selectedDate)")
        print("Spot: \(spot) | SelectedHours: \(selectedHours)")
        print("Spot: \(spot) | SelectedEndDate: \(selectedEndDate)")
        print("Spot: \(spot) | ParsedReservationDate: \(parsedReservationDate)")
        print("Spot: \(spot) | ReservationHours: \(reservationHours)")
        print("Spot: \(spot) | ReservationEndDate: \(reservationEndDate)")
        print("Spot: \(spot) | Beginning within range: \(beginningStatus)")
        print("Spot: \(spot) | End within range: \(endStatus)")
        print("Spot: \(spot) | Date within range: \(status)")
        return status
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
        
        // Update Reservations Table
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let dispatchGroup = DispatchGroup()
        
        for spot in selectedSpots {
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
                selectedLot = nil
                isReserving = false
                dispatchGroup.leave()
            }
        }
        
        // Close the barrier(s)
        for spotId in spotIdsToReserve {
            awsIoTManager.publishMessage(
                parkingLotId: NSNumber(value: parkingLotId),
                spotId: spotId,
                barrierOpen: false
            )
        }
    }
}
#endif
