// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI
import Combine

class ReservationsViewModel: ObservableObject {
    @Published var parkingLots: [ParkingLot] = []
    @Published var errorMessage: String? = nil
    
    func fetchReservations(email: String) {
        DatabaseManager.shared.getUserReservationsWithParkingDetails(email: email) { [weak self] parkingLots, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else if let parkingLots = parkingLots {
                    self?.parkingLots = parkingLots
                }
            }
        }
    }
}
#endif
