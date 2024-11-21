// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI

struct ReservedSpotView: View {
    let parkingLot: ParkingLot
    let reservation: Reservation
    @State var barrierOpen: Bool = false
    
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
                        Text("Date Unknown")
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
                        Text("Time Unknown")
                            .bold()
                    }
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
                        Text("Rs. 888")
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
                        print("Barrier opened")
                    } else {
                        print("Barrier closed")
                    }
                    barrierOpen.toggle()
                } label: {
                    HStack {
                        Spacer()
                        if !barrierOpen {
                            Text("Open Barrier")
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
}
#endif
