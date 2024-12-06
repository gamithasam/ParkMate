// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import Foundation

struct ReservationDetail: Identifiable {
    var id: String { reservation.reservationId ?? UUID().uuidString }
    let reservation: Reservation
    let parkingLot: ParkingLot
}
#endif
