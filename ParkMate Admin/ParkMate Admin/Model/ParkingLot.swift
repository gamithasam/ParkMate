import Foundation
import AWSCore
import AWSDynamoDB

class ParkingLot: AWSDynamoDBObjectModel, AWSDynamoDBModeling, Identifiable {
    @objc var parkingLotId: NSNumber?
    @objc var name: String?
    @objc var city: String?
    @objc var latitude: NSNumber?
    @objc var longitude: NSNumber?
    @objc var pic: String?
    @objc var price: [String: NSNumber]?

    class func dynamoDBTableName() -> String {
        return "ParkingLots" // Replace with your DynamoDB table name
    }

    class func hashKeyAttribute() -> String {
        return "parkingLotId"
    }
}
