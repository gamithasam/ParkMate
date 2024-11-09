// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI

struct ParkingLotView: View {
    @State private var selectedDateNTime: Date = Date()
    @State private var hours: Int = 1
    @State private var selectedVehicle: Int = 0
    @State private var vehicles: [VehicleData] = []
    var parkinglot: ParkingLot
    
    let vehicleTypes = ["Car", "Bicycle", "Motorcycle", "Truck"]
    let vehicleIcons = ["car.fill", "bicycle", "motorcycle.fill", "truck.box.fill"]

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
                        ForEach(vehicles.indices, id: \.self) { index in
                            let vehicle = vehicles[index]
                            Label {
                                Text(vehicle.licensePlate ?? "Unknown")
                            } icon: {
                                let iconIndex = vehicleTypes.firstIndex(of: vehicle.type!) ?? 0
                                Image(systemName: vehicleIcons[iconIndex])
                                    .foregroundColor(.blue)
                            }
                            .tag(index)
                        }
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
        .onAppear {
            loadVehiclesFromUserDefaults()
        }
    }
    
    private func loadVehiclesFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "userVehicles") {
            do {
                let decoder = JSONDecoder()
                vehicles = try decoder.decode([VehicleData].self, from: data)
            } catch {
                print("Failed to decode vehicles: \(error)")
                // Handle the error appropriately
            }
        } else {
            print("No vehicles found in UserDefaults.")
        }
    }
}
#endif
