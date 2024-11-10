// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct ReservationsView: View {
    
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
                
                Section {
                    NavigationLink(destination: ReservedSpotView()) {
                        HStack {
//                            if let _ = parkinglot!.pic, let url = URL(string: parkinglot!.pic!) {
//                                AsyncImage(url: url) { phase in
//                                    switch phase {
//                                    case .empty:
//                                        ProgressView()
//                                            .frame(width: 80, height: 80)
//                                            .cornerRadius(10)
//                                    case .success(let image):
//                                        image
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fill)
//                                            .frame(width: 80, height: 80)
//                                            .cornerRadius(10)
//                                            .clipped()
//                                    case .failure:
//                                        Image("Logo") // TODO: Show a placeholder if image loading fails
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fill)
//                                            .frame(width: 80, height: 80)
//                                            .cornerRadius(10)
//                                            .clipped()
//                                    @unknown default:
//                                        EmptyView()
//                                            .frame(width: 80, height: 80)
//                                            .cornerRadius(10)
//                                    }
//                                }
//                            } else {
                                FailedImageView() // Show a default placeholder if URL is nil
//                            }
                            VStack(alignment: .leading) {
//                                Text(parkinglot!.name ?? "Car Park Name")
                                Text("KCC Car Park")

                                    .font(.headline)
//                                Text(parkinglot!.city ?? "City")
                                Text("Kandy")

                                    .font(.caption)
                                Spacer()
                                HStack(alignment: .bottom) {
                                    Text("3:00 PM")
                                        .font(.body)
                                    Text("11/12/2024")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.leading, 16)
                        }
                        .padding(9)
                    }
                    
                    
                    NavigationLink(destination: ReservedSpotView()) {
                        HStack {
//                            if let _ = parkinglot!.pic, let url = URL(string: parkinglot!.pic!) {
//                                AsyncImage(url: url) { phase in
//                                    switch phase {
//                                    case .empty:
//                                        ProgressView()
//                                            .frame(width: 80, height: 80)
//                                            .cornerRadius(10)
//                                    case .success(let image):
//                                        image
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fill)
//                                            .frame(width: 80, height: 80)
//                                            .cornerRadius(10)
//                                            .clipped()
//                                    case .failure:
//                                        FailedImageView() // Show a placeholder if image loading fails
//                                    @unknown default:
//                                        EmptyView()
//                                            .frame(width: 80, height: 80)
//                                            .cornerRadius(10)
//                                    }
//                                }
//                            } else {
                                FailedImageView() // Show a default placeholder if URL is nil
//                            }
                            VStack(alignment: .leading) {
//                                Text(parkinglot!.name ?? "Car Park Name")
                                Text("KCC Car Park")

                                    .font(.headline)
//                                Text(parkinglot!.city ?? "City")
                                Text("Kandy")

                                    .font(.caption)
                                Spacer()
                                HStack(alignment: .bottom) {
                                    Text("3:00 PM")
                                        .font(.body)
                                    Text("11/12/2024")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.leading, 16)
                        }
                        .padding(9)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                }
            }
            .navigationTitle("Reservations")
        }
    }
}
