// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import Foundation
import AWSDynamoDB

class DatabaseManager {
    static let shared = DatabaseManager() // Singleton instance
    
    private init() {} // Private initializer for singleton pattern
    
    func fetchUser(email: String, completion: @escaping (User?, Error?) -> Void) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "email = :email" // Changed username to email
        queryExpression.expressionAttributeValues = [":email": email]
        
        dynamoDBObjectMapper.query(User.self, expression: queryExpression) { (output, error) in
            if let error = error {
                completion(nil, error)
            } else if let user = output?.items.first as? User {
                completion(user, nil)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    func fetchVehicles(email: String, completion: @escaping (Vehicle?, Error?) -> Void) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "email = :email" // Changed username to email
        queryExpression.expressionAttributeValues = [":email": email]
        
        dynamoDBObjectMapper.query(Vehicle.self, expression: queryExpression) { (output, error) in
            if let error = error {
                completion(nil, error)
            } else if let vehicle = output?.items.first as? Vehicle {
                completion(vehicle, nil)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    func saveUser(_ user: User, completion: @escaping (Error?) -> Void) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper.save(user) { (error) in
            completion(error)
        }
    }
    
    func fetchParkingSpots(parkingLotId: Int, completion: @escaping ([ParkingSpot]?, Error?) -> Void) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "parkingLotId = :parkingLotId"
        queryExpression.expressionAttributeValues = [":parkingLotId": parkingLotId]
        
        dynamoDBObjectMapper.query(ParkingSpotItem.self, expression: queryExpression) { (output, error) in
            if let error = error {
                completion(nil, error)
            } else if let items = output?.items as? [ParkingSpotItem], let spotsDict = items.first?.spots {
                let parkingSpots = spotsDict.map { ParkingSpot(spotId: $0.key, status: ParkingSpot.SpotStatus(rawValue: $0.value.capitalized) ?? .Available) }
                completion(parkingSpots, nil)
            } else {
                completion([], nil)
            }
        }
    }
}
#endif
