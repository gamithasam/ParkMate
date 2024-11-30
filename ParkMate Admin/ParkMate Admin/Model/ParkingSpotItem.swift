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
