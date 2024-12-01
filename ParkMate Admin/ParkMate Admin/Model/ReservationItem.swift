//
//  ReservationItem.swift
//  ParkMate Admin
//
//  Created by Gamitha Samarasingha on 2024-12-01.
//

import Foundation
import AWSDynamoDB

class ReservationItem: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    @objc var email: String?
    @objc var spotId: String?
    @objc var parkingLotId: NSNumber?
    @objc var dateNTime: String?

    class func dynamoDBTableName() -> String {
        return "Reservations"
    }

    class func hashKeyAttribute() -> String {
        return "email"
    }

    class func dynamoDBIndexKeys() -> [String: String] {
        return ["ParkingLotIdIndex": "parkingLotId"]
    }
}
