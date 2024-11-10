// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import Foundation
import AWSDynamoDB

@objcMembers
class ParkingSpotItem: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var parkingLotId: NSNumber?
    var spots: [String: String]?

    // MARK: - AWSDynamoDBModeling
    class func dynamoDBTableName() -> String {
        return "ParkingSpots"
    }
    
    class func hashKeyAttribute() -> String {
        return "parkingLotId"
    }
}
#endif
