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
                let parkingSpots = spotsDict.map { ParkingSpot(spotId: $0.key, status: ParkingSpot.SpotStatus(rawValue: $0.value) ?? .available) }
                completion(parkingSpots, nil)
            } else {
                completion([], nil)
            }
        }
    }
    
    func reserveParkingSpots(parkingLotId: Int, spotIds: [String], completion: @escaping (Error?) -> Void) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
                
        // Create a ParkingSpotItem with the specified parkingLotId
        let parkingSpotItem = ParkingSpotItem()
        parkingSpotItem!.parkingLotId = NSNumber(value: parkingLotId)
        
        // Fetch the current parking spots
        dynamoDBObjectMapper.load(ParkingSpotItem.self, hashKey: NSNumber(value: parkingLotId), rangeKey: nil) { (item, error) in
            if let error = error {
                completion(error)
                return
            }
            
            guard let existingItem = item as? ParkingSpotItem, var spotsDict = existingItem.spots else {
                let fetchError = NSError(domain: "DatabaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch parking spots."])
                completion(fetchError)
                return
            }
                        
            // Update the status of selected spots to "reserved"
            for spotId in spotIds {
                if let currentStatus = spotsDict[spotId] {
                    spotsDict[spotId] = "reserved"
                }
            }
            
            // Assign the updated spots dictionary back to the item
            existingItem.spots = spotsDict
                        
            // Save the updated item back to DynamoDB
            dynamoDBObjectMapper.save(existingItem) { error in
                completion(error)
            }
        }
    }
}
#endif
