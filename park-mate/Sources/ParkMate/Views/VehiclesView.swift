// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI
import AWSDynamoDB

struct VehicleAdd: Identifiable, Equatable {
    let id = UUID()
    var type: String
    var licensePlate: String
    
    static func == (lhs: VehicleAdd, rhs: VehicleAdd) -> Bool {
        return lhs.type == rhs.type && lhs.licensePlate == rhs.licensePlate
    }
}

struct VehiclesView: View {
    @State private var vehicles: [VehicleAdd] = []
    @State private var originalVehicles: [VehicleAdd] = []
    @State private var licensePlate: String = ""
    @State private var selectedVehicleType: Int = 0
    @State private var alertItem: AlertItem?
    @State private var isSaving: Bool = false
    @State private var changed: Bool = false
    @Environment(\.dismiss) private var dismiss
    @AppStorage("userVehicles") var userVehiclesData: Data = Data()
    var fromLaunch = false
    
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
                
                ClearableTextField(title: "License Plate Number", text: $licensePlate)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Button(action: addVehicle) {
                    Text("Add Vehicle")
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
                
                // List of added vehicles
                List {
                    ForEach(vehicles) { vehicle in
                        HStack {
                            Image(systemName: vehicleIcons[vehicleTypes.firstIndex(of: vehicle.type) ?? 0])
                            Text(vehicle.licensePlate)
                        }
                    }
                    .onDelete(perform: deleteVehicle)
                }
                
                if fromLaunch {
                    Button(action: saveVehicles) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isSaving || !changed)
                }
            }
        }
        .navigationTitle("Vehicles")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: saveVehicles) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
                .disabled(isSaving || !changed || vehicles.isEmpty)
            }
        }
        .onAppear {
            fetchVehicles()
        }
        .alert(item: $alertItem) { alert in
            Alert(
                title: Text("Error"),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func addVehicle() {
        guard !licensePlate.isEmpty else { return }
        
        let vehicleType: String = vehicleTypes[selectedVehicleType]
        let newVehicle = VehicleAdd(type: vehicleType, licensePlate: licensePlate)
        vehicles.append(newVehicle)
        
        changed = true
        
        // Clear the input fields
        selectedVehicleType = 0
        licensePlate = ""
    }
    
    private func deleteVehicle(at offsets: IndexSet) {
        vehicles.remove(atOffsets: offsets)
        changed = true
    }
    
    private func saveVehicles() {
        isSaving = true
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        // Get the user's email from UserDefaults
        guard let userEmail = UserDefaults.standard.string(forKey: "userEmail") else {
            isSaving = false
            print("Email not found in UserDefaults")
            self.alertItem = AlertItem(message: "An error occurred. Please try again.")
            return
        }

        let saveGroup = DispatchGroup()
        
        // Identify deleted vehicles
        let deletedVehicles = originalVehicles.filter { !vehicles.contains($0) }

        // Delete removed vehicles from DynamoDB
        for vehicle in deletedVehicles {
            // Assuming Vehicle has a primary key, e.g., licensePlate and email
            let vehicleItem = Vehicle()
            vehicleItem?.licensePlate = vehicle.licensePlate
            vehicleItem?.email = userEmail
            
            saveGroup.enter()
            dynamoDBObjectMapper.remove(vehicleItem!) { error in
                if let error = error {
                    print("Failed to delete vehicle: \(error)")
                    self.alertItem = AlertItem(message: "An error occurred while deleting. Please try again.")
                }
                saveGroup.leave()
            }
        }

        for vehicle in vehicles {
            let vehicleItem = Vehicle()
            vehicleItem!.type = vehicle.type
            vehicleItem!.licensePlate = vehicle.licensePlate
            vehicleItem!.email = userEmail

            saveGroup.enter()
            dynamoDBObjectMapper.save(vehicleItem!) { error in
                if let error = error {
                    print("Failed to save vehicle: \(error)")
                    self.alertItem = AlertItem(message: "An error occurred. Please try again.")
                }
                saveGroup.leave()
            }
        }
        
        // Serialize the vehicles array
        let vehicleDataArray = vehicles.map { vehicle -> VehicleData in
            return VehicleData(
                type: vehicle.type,
                licensePlate: vehicle.licensePlate
            )
        }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(vehicleDataArray)
            userVehiclesData = data
            print("Vehicles saved to UserDefaults.")
        } catch {
            print("Failed to encode vehicles: \(error)")
            self.alertItem = AlertItem(message: "An error occurred. Please try again.")
        }

        saveGroup.notify(queue: .main) {
            isSaving = false
            print("All vehicles saved successfully.")
            if !fromLaunch {
                print("Dismissing")
                dismiss()
            }
        }
    }

    private func fetchVehicles() {
        if !userVehiclesData.isEmpty {
            do {
                let decoder = JSONDecoder()
                let vehicleDataArray = try decoder.decode([VehicleData].self, from: userVehiclesData)
                vehicles = vehicleDataArray.map { data -> VehicleAdd in
                    return VehicleAdd(
                        type: data.type!,
                        licensePlate: data.licensePlate!
                    )
                }
            } catch {
                print("Failed to decode vehicles: \(error)")
            }
        }
    }
}
#endif
