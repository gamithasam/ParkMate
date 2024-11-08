// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI

struct ParkingLotView: View {
    @State private var selectedDateNTime: Date = Date()
    @State private var hours: Int = 0
    @State private var selectedVehicle: Int = 0
    var parkinglot: ParkingLot

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Date and Time")) {
                    DatePicker("Start Time", selection: $selectedDateNTime)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                    HStack {
                        Text("Hours:")
                        Spacer()
                        Stepper(value: $hours, in: 0...10) {
                            Text("\(hours)") // Display the actual value
                        }
                    }
                }
                
                Section(header: Text("Vehicle")) {
                    Picker("Vehicle", selection: $selectedVehicle) {
                        Label {
                            Text("ABC-1234")
                        } icon: {
                            Image(systemName: "car.fill")
                                .foregroundColor(.blue)
                        }.tag(0)
                        
                        Label {
                            Text("FHR-4541")
                        } icon: {
                            Image(systemName: "car.fill")
                                .foregroundColor(.blue)
                        }.tag(1)
                        
                        Label {
                            Text("DVD-2313")
                        } icon: {
                            Image(systemName: "truck.box.fill")
                                .foregroundColor(.blue)
                        }.tag(2)
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section() {
                    HStack {
                        Spacer()
                        Text("Rs."+String(parkinglot.price?.intValue ?? 888))
                            .font(.body)
                            .bold()
                        Spacer()
                    }
                }
                
                Section() {
                    Button(action: {
                        // Your action here
                        print("Next")
                    }) {
                        HStack {
                            Spacer()
                            Text("Next")
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(parkinglot.name ?? "Parking Lot")
        }
    }
}
#endif
