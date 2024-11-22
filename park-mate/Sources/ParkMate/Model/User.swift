// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import Foundation
import AWSDynamoDB

class User: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    @objc var email: String?
    @objc var firstName: String?
    @objc var lastName: String?
    @objc var password: String?
    @objc var birthday: String?
    @objc var salt: String?
    @objc var payables: NSNumber?

    static func dynamoDBTableName() -> String {
        return "Users"
    }

    static func hashKeyAttribute() -> String {
        return "email"
    }
}
#endif
