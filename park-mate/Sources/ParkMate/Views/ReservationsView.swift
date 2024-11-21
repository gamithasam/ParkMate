// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct ReservationsView: View {
    #if !SKIP
    @StateObject private var viewModel = ReservationsViewModel()
    @State private var alertItem: AlertItem?
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
                                                    .frame(width: 80, height: 80)
                                            @unknown default:
                                                EmptyView()
                                                    .frame(width: 80, height: 80)
                                                    .cornerRadius(10)
                                            }
                                        }
                                    } else {
                                        FailedImageView()
                                            .frame(width: 80, height: 80)
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
                // Get the user's email from UserDefaults
                guard let userEmail = UserDefaults.standard.string(forKey: "userEmail") else {
                    print("Email not found in UserDefaults")
                    self.alertItem = AlertItem(message: "An error occurred. Please try again.")
                    return
                }
                viewModel.fetchReservations(email: userEmail)
            }
            .alert(item: $alertItem) { alert in
                Alert(
                    title: Text("Error"),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            #endif
        }
    }
}
