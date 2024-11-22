// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation
import OSLog
import SwiftUI
#if !SKIP
import AWSCore
import AWSIoT
#endif

let logger: Logger = Logger(subsystem: "com.skip.parkmate", category: "ParkMate")

/// The Android SDK number we are running against, or `nil` if not running on Android
let androidSDK = ProcessInfo.processInfo.environment["android.os.Build.VERSION.SDK_INT"].flatMap({ Int($0) })

/// The shared top-level view for the app, loaded from the platform-specific App delegates below.
///
/// The default implementation merely loads the `ContentView` for the app and logs a message.
public struct RootView : View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("userVehicles") var userVehiclesData: Data = Data()

    public init() {
        #if !SKIP
        // Initialize AWS Configurations
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "AKIA5G2VG4SUUQKNSDO2", secretKey: "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")
        let configuration = AWSServiceConfiguration(region: .EUNorth1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let iotDataManagerKey = "MyAWSIoTDataManager"
                
        // Corrected IoT endpoint with protocol
        let iotEndPoint = AWSEndpoint(urlString: "wss://a2fcyk7jrcl2w-ats.iot.eu-north-1.amazonaws.com")
        
        // Create a new service configuration for IoT
        let iotDataConfiguration = AWSServiceConfiguration(
            region: configuration!.regionType,
            endpoint: iotEndPoint,
            credentialsProvider: configuration!.credentialsProvider
        )
        
        // Register the IoT Data Manager with the new configuration
        AWSIoTDataManager.register(
            with: iotDataConfiguration!,
            forKey: iotDataManagerKey
        )
        
        let iotDataManager = AWSIoTDataManager(forKey: iotDataManagerKey)
        
        // Connect once during app initialization
        iotDataManager.connectUsingWebSocket(
            withClientId: UUID().uuidString,
            cleanSession: true
        ) { status in
            switch status {
            case .connected:
                print("Connected to AWS IoT")
            case .connecting:
                print("Connecting to AWS IoT")
            case .disconnected:
                print("Disconnected from AWS IoT")
            case .connectionError:
                print("Connection Error with AWS IoT")
            case .connectionRefused:
                print("Connection Refused by AWS IoT")
//            case .connectionIdle:
//                print("Connection Idle with AWS IoT")
            default:
                print("Unknown connection status")
            }
        }
        #endif
    }

//    public var body: some View {
//        Group {
//            #if !SKIP
//            if !isLoggedIn {
//                OnboardingView()
//            } else if !hasVehicles {
//                NavigationStack {
//                    VehiclesView()
//                        .navigationBarBackButtonHidden(true)
//                }
//            } else {
//                ContentView()
//            }
//            #else
//            ContentView()
//            #endif
//        }
//        .onAppear {
//            // Check login and vehicles states when app launches
//            checkLoginStatus()
//            print("hasVehicles: \(hasVehicles)")
////            checkVehiclesStatus()
//        }
//    }
    @ViewBuilder
    public var body: some View {
        #if !SKIP
        if !isLoggedIn {
            OnboardingView()
        } else if userVehiclesData.isEmpty {
            VehiclesView(fromLaunch: true)
        } else {
            ContentView()
        }
        #else
        ContentView()
        #endif
    }
        
    
    private func checkLoginStatus() {
        // Check if user is logged in using UserDefaults
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
//    private func checkVehiclesStatus() {
//        // Check if vehicles are empty in using UserDefaults
//        hasVehicles = UserDefaults.standard.bool(forKey: "hasVehicles")
//    }
}

#if !SKIP
public protocol ParkMateApp : App {
}

/// The entry point to the ParkMate app.
/// The concrete implementation is in the ParkMateApp module.
public extension ParkMateApp {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
#endif
