// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct ReservationsView: View {
    #if !SKIP
    @StateObject private var viewModel = ReservationsViewModel()
    #endif
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 25) {
                        HStack {
                            Text("Payables")
                                .font(.title3)
                                .bold()
                            Spacer()
                            Text("Rs.888")
                                .font(.title3)
                        }
                        Button(action: {
                            // TODO: Payment
                            print("Payed")
                        }) {
                            Text("Pay")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 25)
                    .padding(.horizontal, 20)
                }
                #if !SKIP
                .listRowInsets(EdgeInsets())
                #endif
                
                #if !SKIP
                Section {
                    if viewModel.errorMessage != nil {
                        Text("Error: \(viewModel.errorMessage!)")
                    } else if viewModel.parkingLots.isEmpty {
                        Text("No reservations found.")
                    } else {
                        ForEach(viewModel.parkingLots.indices, id: \.self) { index in
                            let parkingLot = viewModel.parkingLots[index]
                            NavigationLink(destination: ReservedSpotView()) {
                                HStack {
                                    if let picURL = parkingLot.pic, let url = URL(string: picURL) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(width: 80, height: 80)
                                                    .cornerRadius(10)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 80, height: 80)
                                                    .cornerRadius(10)
                                                    .clipped()
                                            case .failure:
                                                FailedImageView()
                                            @unknown default:
                                                EmptyView()
                                                    .frame(width: 80, height: 80)
                                                    .cornerRadius(10)
                                            }
                                        }
                                    } else {
                                        FailedImageView()
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text(parkingLot.name ?? "Car Park Name")
                                            .font(.headline)
                                        Text(parkingLot.city ?? "City")
                                            .font(.caption)
                                        
//                                        Spacer()
                                        
//                                        // Time and Date
//                                        HStack(alignment: .bottom) {
//                                            Text(getFormattedTime(reservation.dateNTime))
//                                                .font(.body)
//                                            Text(getFormattedDate(reservation.dateNTime))
//                                                .font(.caption)
//                                                .foregroundColor(.secondary)
//                                        }
                                    }
                                    .padding(.leading, 16)
                                }
                            }
                        }
                    }
                }
                #endif
            }
            .navigationTitle("Reservations")
            #if !SKIP
            .onAppear {
                viewModel.fetchReservations(email: "gamitha@asia.com")
            }
            #endif
        }
    }
    
    private func getFormattedDate(from dateNTime: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd MMM yyyy 'at' h:mm:ss a"
        
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "MM/dd/yyyy"
        
        if let date = inputFormatter.date(from: dateNTime) {
            return outputDateFormatter.string(from: date)
        } else {
            return nil
        }
    }

    private func getFormattedTime(from dateNTime: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd MMM yyyy 'at' h:mm:ss a"
        
        let outputTimeFormatter = DateFormatter()
        outputTimeFormatter.dateFormat = "h:mm a"
        
        if let date = inputFormatter.date(from: dateNTime) {
            return outputTimeFormatter.string(from: date)
        } else {
            return nil
        }
    }
}
