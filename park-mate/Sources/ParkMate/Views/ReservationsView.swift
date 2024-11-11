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
                    } else if viewModel.reservationDetails.isEmpty { // Changed from parkingLots
                        Text("No reservations found.")
                    } else {
                        ForEach(viewModel.reservationDetails) { detail in // Use Identifiable
                            let parkingLot = detail.parkingLot
                            let reservation = detail.reservation
                            
                            NavigationLink(destination: ReservedSpotView(parkingLot: parkingLot, reservation: reservation)) {
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

                                        Spacer()
                                        
                                        ReservationDateTimeView(dateNTime: reservation.dateNTime ?? "")
                                    }
                                    .padding(.leading, 16)
                                }
                                .padding(9)
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
}
