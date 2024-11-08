// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
import SwiftUI
import AWSDynamoDB

struct VehicleAdd: Identifiable {
    let id = UUID()
    var type: String
    var licensePlate: String
}

struct VehiclesView: View {
    @State private var vehicles: [VehicleAdd] = []
    @State private var licensePlate: String = ""
    @State private var selectedVehicleType: Int = 0
    @State private var alertItem: AlertItem?
    @State private var isSaving: Bool = false
    @State private var changed: Bool = false
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasVehicles") private var hasVehicles = false
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

        saveGroup.notify(queue: .main) {
            isSaving = false
            print("All vehicles saved successfully.")
//            UserDefaults.standard.set(true, forKey: "hasVehicles")
            if !fromLaunch {
                print("Dismissing")
                dismiss()
            } else {
                print("Changing hasVehicles")
                hasVehicles = true
            }
        }
    }

    private func fetchVehicles() {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        
        // Get the user's email from UserDefaults
        guard let userEmail = UserDefaults.standard.string(forKey: "userEmail") else {
            print("Email not found in UserDefaults")
            self.alertItem = AlertItem(message: "An error occurred. Please try again.")
            dismiss()
            return
        }
        
        // Set the key condition expression
        queryExpression.keyConditionExpression = "#email = :emailValue"
        
        // Set the expression attribute names and values
        queryExpression.expressionAttributeNames = ["#email": "email"]
        queryExpression.expressionAttributeValues = [":emailValue": userEmail]

        dynamoDBObjectMapper.query(Vehicle.self, expression: queryExpression) { (output, error) in
            if let error = error {
                print("Failed to fetch vehicles: \(error)")
                self.alertItem = AlertItem(message: "An error occurred. Please try again.")
                dismiss()
            } else if let items = output?.items as? [Vehicle] {
                DispatchQueue.main.async {
                    self.vehicles = items.compactMap { item in
                        if let type = item.type, let licensePlate = item.licensePlate {
                            return VehicleAdd(type: type, licensePlate: licensePlate)
                        }
                        return nil
                    }
                }
            }
        }
    }
}
#endif
