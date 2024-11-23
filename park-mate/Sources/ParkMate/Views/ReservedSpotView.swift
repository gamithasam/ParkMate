// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI
import AWSIoT

struct ReservedSpotView: View {
    let parkingLot: ParkingLot
    let reservation: Reservation
    @State var barrierOpen: Bool = false
    @State var alertItem: AlertItem?
    
    // Retrieve the IoT Data Manager
    let iotDataManager = AWSIoTDataManager(forKey: "MyAWSIoTDataManager")
    
    var body: some View {
        List {
            Section {
                if let picURL = parkingLot.pic, let url = URL(string: picURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 185)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(10)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 185)
                                .cornerRadius(10)
                                .clipped()
                        case .failure:
                            FailedImageView()
                                .frame(height: 185)
                                .frame(maxWidth: .infinity)
                        @unknown default:
                            EmptyView()
                                .frame(height: 80)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    FailedImageView()
                        .frame(height: 185)
                        .frame(maxWidth: .infinity)
                }
            }
            #if !SKIP
            .listRowInsets(EdgeInsets())
            #endif
            
            Section(header: Text("General Info")) {
                HStack {
                    Text("Parking Spot")
                    Spacer()
                    Text(reservation.spotId ?? "Unknown")
                        .bold()
                }
                HStack {
                    Text("Date")
                    Spacer()
                    if let dateObject = parseDate(from: reservation.dateNTime!) {
                        Text(formatDate(dateObject))
                            .bold()
                    } else {
                        Text("Unknown")
                            .bold()
                    }
                }
                HStack {
                    Text("Time")
                    Spacer()
                    if let dateObject = parseDate(from: reservation.dateNTime!) {
                        Text(formatTime(dateObject))
                            .bold()
                    } else {
                        Text("Unknown")
                            .bold()
                    }
                }
                HStack {
                    Text("Hours")
                    Spacer()
                    Text("\(reservation.hours?.stringValue ?? "Unknown") hour(s)")
                        .bold()
                }
            }
            
            Section(header: Text("Vehicle")) {
                HStack {
                    Text("Vehicle")
                    Spacer()
                    Text(reservation.vehicle ?? "Car")
                        .bold()
                }
            }
            
            Section {
                HStack {
                    Spacer()
                    VStack {
                        Text("Price")
                            .foregroundColor(.blue)
                            .bold()
                        Text(String(format: "Rs. %.2f", reservation.price?.doubleValue ?? 888.88))
                            .font(.title2)
                            .bold()
                    }
                    .frame(height: 88)
                    Spacer()
                }
            }
            
            Section {
                Button {
                    if !barrierOpen {
                        alertItem = AlertItem(message: "Are you sure you want to open the barrier?")
                    } else {
                        print("Barrier closed")
                        publishMessage()
                        barrierOpen.toggle()
                    }
                } label: {
                    HStack {
                        Spacer()
                        if !barrierOpen {
                            Text("Open Barrier")
                                .foregroundColor(.red)
                        } else {
                            Text("Close Barrier")
                        }
                        Spacer()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle(parkingLot.name ?? "Parking Lot")
        .alert(item: $alertItem) { alertItem in
            Alert(
                title: Text("Confirmation"),
                message: Text(alertItem.message),
                primaryButton: .default(Text("Yes")) {
                    print("Barrier opened")
                    publishMessage()
                    barrierOpen.toggle()
                },
                secondaryButton: .cancel(Text("No")) {
                    print("Barrier remains closed")
                }
            )
        }
        .onAppear {
            print(reservation.price!)
        }
    }
    
    // Function to parse the date string back into a Date object
    func parseDate(from dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.date(from: dateString)
    }

    // Function to format a Date object into a custom date string
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d yyyy" // Desired format: "Nov 12 2024"
        return formatter.string(from: date)
    }

    // Function to format a Date object into a custom time string
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // Desired format: "3:00 PM"
        return formatter.string(from: date)
    }
    
    func publishMessage() {
        guard iotDataManager.getConnectionStatus() == .connected else {
            print("Not connected to AWS IoT Core")
            return
        }
        
        let message = """
            {
              "parkingLotId": \(reservation.parkingLotId!),
              "spotId": "\(reservation.spotId!)",
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
