// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import AWSIoT

class IoTManager {
    private let iotDataManager: AWSIoTDataManager

    init() {
        self.iotDataManager = AWSIoTDataManager(forKey: "MyAWSIoTDataManager")
    }

    func publishMessage(parkingLotId: NSNumber, spotId: String, barrierOpen: Bool) {
        guard iotDataManager.getConnectionStatus() == .connected else {
            print("Not connected to AWS IoT Core")
            return
        }

        let message = """
            {
              "parkingLotId": \(parkingLotId),
              "spotId": "\(spotId)",
              "barrier": \(barrierOpen ? 0 : 1)
            }
            """
        let topic = "lots/barriers"

        iotDataManager.publishString(
            message,
            onTopic: topic,
            qoS: .messageDeliveryAttemptedAtLeastOnce
        )
        print("Published")
    }
}
#endif
