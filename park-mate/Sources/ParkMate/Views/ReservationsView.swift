// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI
#if !SKIP
import AWSDynamoDB
#endif

struct ReservationsView: View {
    #if !SKIP
    @StateObject private var viewModel = ReservationsViewModel()
    @State private var alertItem: AlertItem?
    @State private var payables: Double = 0.0
    @State private var showMockPaymentSheet = false
    #endif
    
    var body: some View {
        NavigationStack {
            List {
                #if !SKIP
                if payables != 0.0 {
                    Section {
                        VStack(spacing: 25) {
                            HStack {
                                Text("Payables")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                                Text(String(format: "Rs. %.2f", payables))
                                    .font(.title3)
                            }
                            Button(action: {
                                showMockPaymentSheet = true
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
                    .listRowInsets(EdgeInsets())
                }
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
                fetchUserDetails(email: userEmail)
            }
            .alert(item: $alertItem) { alert in
                Alert(
                    title: Text("Error"),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showMockPaymentSheet) {
                MockPaymentSheet(
                    title: "Payables",
                    price: self.payables,
                    onPaymentCompleted: {
    //                    handlePayment()
                        print("Payed")
                    }
                )
                .presentationDetents([.medium])
            }
            #endif
        }
    }
    
    #if !SKIP
    func fetchUserDetails(email: String) {
        // Configure AWS DynamoDB
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        // Create the user key
        let userKey = User()
        userKey!.email = email
        
        // Fetch the user data
        dynamoDBObjectMapper.load(User.self, hashKey: email, rangeKey: nil).continueWith { (task: AWSTask<AnyObject>!) -> Any? in
            if let error = task.error {
                print("Error fetching user details: \(error.localizedDescription)")
                self.alertItem = AlertItem(message: "An error occurred. Please try again.")
            } else if let user = task.result as? User {
                DispatchQueue.main.async {
                    if let payables = user.payables {
                        self.payables = payables.doubleValue
                    } else {
                        // Handle the nil case here
                        print("Payables is nil")
                        self.alertItem = AlertItem(message: "An error occurred. Please try again.")
                        self.payables = 0.00
                    }
                }
            }
            return nil
        }
    }
    #endif
}
