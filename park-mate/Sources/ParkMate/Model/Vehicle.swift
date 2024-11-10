// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import Foundation
import AWSDynamoDB

class Vehicle: AWSDynamoDBObjectModel, AWSDynamoDBModeling, Encodable {
    @objc var email: String?
    @objc var type: String?
    @objc var licensePlate: String?

    static func dynamoDBTableName() -> String {
        return "Vehicles"
    }

    static func hashKeyAttribute() -> String {
        return "email"
    }

    static func rangeKeyAttribute() -> String {
        return "licensePlate"
    }
}

struct VehicleData: Codable {
    var type: String?
    var licensePlate: String?
}
#endif
