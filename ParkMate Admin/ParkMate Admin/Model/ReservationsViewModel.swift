//
//  ReservationsViewModel.swift
//  ParkMate Admin
//
//  Created by Gamitha Samarasingha on 2024-12-01.
//
import SwiftUI
import Combine

class ReservationsViewModel: ObservableObject {
    @Published var reservationsDict: [String: ReservationItem] = [:]
    @Published var errorMessage: String?

    func fetchReservations(parkingLotId: Int) {
        DatabaseManager.shared.fetchReservations(parkingLotId: parkingLotId) { [weak self] (reservations, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Error fetching reservations: \(error.localizedDescription)"
                } else if let reservations = reservations {
                    for reservation in reservations {
                        if let spotId = reservation.spotId {
                            self?.reservationsDict[spotId] = reservation
                        }
                    }
                }
            }
        }
    }
}
