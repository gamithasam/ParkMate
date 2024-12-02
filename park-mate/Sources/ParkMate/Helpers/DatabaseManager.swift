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
    
    func fetchReservations(email: String, completion: @escaping ([Reservation]?, Error?) -> Void) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()

        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "email = :email"
        queryExpression.expressionAttributeValues = [":email": email]

        dynamoDBObjectMapper.query(Reservation.self, expression: queryExpression) { (output, error) in
            if let error = error {
                completion(nil, error)
            } else if let reservations = output?.items as? [Reservation] {
                completion(reservations, nil)
            } else {
                completion([], nil)
            }
        }
    }
    
    func fetchParkingLot(parkingLotId: NSNumber, completion: @escaping (ParkingLot?, Error?) -> Void) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()

        dynamoDBObjectMapper.load(ParkingLot.self, hashKey: parkingLotId, rangeKey: nil) { (item, error) in
            if let error = error {
                completion(nil, error)
            } else if let parkingLot = item as? ParkingLot {
                completion(parkingLot, nil)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    func getUserReservationsWithParkingDetails(email: String, completion: @escaping ([ReservationDetail]?, Error?) -> Void) {
        fetchReservations(email: email) { reservations, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let reservations = reservations, !reservations.isEmpty else {
                completion([], nil)
                return
            }

            var reservationDetails: [ReservationDetail] = []
            let group = DispatchGroup()

            for reservation in reservations {
                guard let parkingLotId = reservation.parkingLotId else { continue }
                group.enter()
                self.fetchParkingLot(parkingLotId: parkingLotId) { parkingLot, error in
                    if let parkingLot = parkingLot {
                        let detail = ReservationDetail(reservation: reservation, parkingLot: parkingLot)
                        reservationDetails.append(detail)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(reservationDetails, nil)
            }
        }
    }
    
    func fetchAllReservations(parkingLotId: Int, completion: @escaping ([Reservation]?, Error?) -> Void) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "ParkingLotIdIndex" // Ensure this matches your GSI name
        queryExpression.keyConditionExpression = "parkingLotId = :parkingLotId"
        queryExpression.expressionAttributeValues = [":parkingLotId": parkingLotId]
        
        dynamoDBObjectMapper.query(Reservation.self, expression: queryExpression) { (output, error) in
            if let error = error {
                completion(nil, error)
            } else if let items = output?.items as? [Reservation] {
                completion(items, nil)
            } else {
                completion([], nil)
            }
        }
    }
}
#endif
