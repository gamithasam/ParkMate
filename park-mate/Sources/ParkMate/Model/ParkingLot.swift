// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
#if !SKIP
import Foundation
import AWSCore
import AWSDynamoDB

class ParkingLot: AWSDynamoDBObjectModel, AWSDynamoDBModeling, Identifiable {
    @objc var parkingLotId: NSNumber?
    @objc var name: String?
    @objc var city: String?
    @objc var latitude: NSNumber?
    @objc var longitude: NSNumber?

    class func dynamoDBTableName() -> String {
        return "ParkingLots" // Replace with your DynamoDB table name
    }

    class func hashKeyAttribute() -> String {
        return "parkingLotId"
    }
}
#endif
