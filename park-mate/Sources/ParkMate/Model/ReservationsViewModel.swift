// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI
import Combine

class ReservationsViewModel: ObservableObject {
    @Published var reservationDetails: [ReservationDetail] = []
    @Published var errorMessage: String? = nil
    
    func fetchReservations(email: String) {
        DatabaseManager.shared.getUserReservationsWithParkingDetails(email: email) { [weak self] reservationDetails, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else if let reservationDetails = reservationDetails {
                    self?.reservationDetails = reservationDetails
                }
            }
        }
    }
}
#endif
