// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

struct ParkingLot: Codable {
    let parkingLotId: Int
    let name: String
    let city: String
    let latitude: Double
    let longitude: Double
}
