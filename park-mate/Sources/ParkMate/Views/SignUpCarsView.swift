// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI

struct Vehicle: Identifiable {
    let id = UUID()
    var type: String
    var licensePlate: String
}

struct SignUpCarsView: View {
    @State private var vehicles: [Vehicle] = []
    @State private var licensePlate: String = ""
    @State private var selectedVehicleType: Int = 0
    
    let vehicleTypes = ["Car", "Bicycle", "Motorcycle", "Truck"]
    let vehicleIcons = ["car.fill", "bicycle", "motorcycle.fill", "truck.box.fill"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Input fields
                Picker(selection: $selectedVehicleType, label: Text("Select Vehicle")) {
                    ForEach(0..<vehicleTypes.count) { index in
                        HStack {
                            Image(systemName: vehicleIcons[index])
                            Text(vehicleTypes[index])
                        }.tag(index)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .padding()
                
                TextField("License Plate Number", text: $licensePlate)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // Add Vehicle Button
                Button(action: addVehicle) {
                    Text("Add Vehicle")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                // List of added vehicles
                List {
                    ForEach(vehicles) { vehicle in
                        VStack(alignment: .leading) {
                            Text("Type: \(vehicle.type)")
                            Text("License Plate: \(vehicle.licensePlate)")
                        }
                    }
                    .onDelete(perform: deleteVehicle)
                }
                
                // Continue Button
                Button(action: proceedToNextScreen) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Add Vehicles")
        }
    }
    
    private func addVehicle() {
        guard !licensePlate.isEmpty else { return }
        
        let vehicleType: String = vehicleTypes[selectedVehicleType]
        let newVehicle = Vehicle(type: vehicleType, licensePlate: licensePlate)
        vehicles.append(newVehicle)
        
        // Clear the input fields
        selectedVehicleType = 0
        licensePlate = ""
    }
    
    private func deleteVehicle(at offsets: IndexSet) {
        vehicles.remove(atOffsets: offsets)
    }
    
    private func proceedToNextScreen() {
        // Implement navigation to next screen
        // You can also validate if at least one vehicle is added
    }
}
#endif
