// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI
#if !SKIP
import AWSDynamoDB
#endif

struct PersonalInfoView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var birthday: Date = Date()
    
    var body: some View {
        Form {
            HStack {
                Text("First Name")
                ClearableTextField(title: "required", text: $firstName)
            }
            HStack {
                Text("Last Name")
                ClearableTextField(title: "required", text: $lastName)
            }
            HStack {
                DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
            }
        }
        .navigationTitle("Personal Information")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    // Add your save action here
//                    saveData()
                }
            }
        }
        #if !SKIP
        .onAppear {
            fetchUserDetails()
        }
        #endif
    }
    
    #if !SKIP
    func fetchUserDetails() {
        // Get the user's email from UserDefaults
        guard let email = UserDefaults.standard.string(forKey: "userEmail") else {
            print("Email not found in UserDefaults")
            return
        }
        
        // Configure AWS DynamoDB
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        // Create the user key
        let userKey = User()
        userKey!.email = email
        
        // Fetch the user data
        dynamoDBObjectMapper.load(User.self, hashKey: email, rangeKey: nil).continueWith { (task: AWSTask<AnyObject>!) -> Any? in
            if let error = task.error {
                print("Error fetching user details: \(error.localizedDescription)")
            } else if let user = task.result as? User {
                DispatchQueue.main.async {
                    self.firstName = user.firstName ?? ""
                    self.lastName = user.lastName ?? ""
                    // Convert birthday string to Date
                    if let birthdayString = user.birthday, let date = self.stringToDate(birthdayString) {
                        self.birthday = date
                    }
                }
            }
            return nil
        }
    }
    
    func stringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.date(from: dateString)
    }
    #endif
}
