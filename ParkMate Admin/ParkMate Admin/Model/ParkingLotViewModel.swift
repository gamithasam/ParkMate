import Foundation
import AWSCore
import AWSDynamoDB
import Combine

class ParkingLotViewModel: ObservableObject {
    @Published var parkingLots: [ParkingLot] = []

    init() {
        fetchParkingLots()
    }

    func fetchParkingLots() {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()

        objectMapper.scan(ParkingLot.self, expression: scanExpression).continueWith { (task: AWSTask<AWSDynamoDBPaginatedOutput>) -> Any? in
            if let error = task.error {
                print("DynamoDB Scan Error: \(error.localizedDescription)")
            } else if let result = task.result, let items = result.items as? [ParkingLot] {
                DispatchQueue.main.async {
                    self.parkingLots = items
                }
            }
            return nil
        }
    }
}
