// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
#if !SKIP
import SwiftUI

struct CarousalView: View {
    @StateObject private var viewModel: ParkingLotViewModel = ParkingLotViewModel()
    @State private var selectedLot: ParkingLot? = nil
    
    var body: some View {
        HStack(spacing: 15) {
            Spacer()
                .frame(width: 5) // 15+5=20
            ForEach(viewModel.parkingLots, id: \.self) { lot in
                CardView(parkinglot: lot)
                    .onTapGesture {
                        selectedLot = lot
                    }
                    .sheet(item: $selectedLot) { selectedLot in
                        ParkingLotView(parkinglot: selectedLot, selectedLot: $selectedLot)
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                    }
            }
        }
    }
}
#endif
