// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI
import Combine

class AllReservationsViewModel: ObservableObject {
    @Published var reservationsDict: [String: Reservation] = [:]
    @Published var errorMessage: String?

    func fetchAllReservations(parkingLotId: Int) {
        DatabaseManager.shared.fetchAllReservations(parkingLotId: parkingLotId) { [weak self] (reservations, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Error fetching reservations: \(error.localizedDescription)"
                } else if let reservations = reservations {
                    for reservation in reservations {
                        if let spotId = reservation.spotId {
                            self?.reservationsDict[spotId] = reservation
                        }
                    }
                }
            }
        }
    }
}
#endif
