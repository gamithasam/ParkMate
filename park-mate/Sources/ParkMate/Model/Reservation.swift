// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import Foundation
import AWSDynamoDB

class Reservation: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    @objc var email: String?
    @objc var parkingLotId: NSNumber?
    @objc var spotId: String?
    @objc var dateNTime: String?
    @objc var vehicle: String?

    static func dynamoDBTableName() -> String {
        return "Reservations"
    }

    static func hashKeyAttribute() -> String {
        return "email"
    }
}
#endif
