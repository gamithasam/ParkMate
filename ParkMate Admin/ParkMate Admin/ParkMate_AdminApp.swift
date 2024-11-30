//
//  ParkMate_AdminApp.swift
//  ParkMate Admin
//
//  Created by Gamitha Samarasingha on 2024-12-01.
//

import SwiftUI
import AWSCore

@main
struct ParkMate_AdminApp: App {
    init() {
        if let configPath = Bundle.main.path(forResource: "AWSConfig", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: configPath),
           let accessKey = config["AccessKey"] as? String,
           let secretKey = config["SecretKey"] as? String,
           let regionString = config["Region"] as? String,
           let region = AWSRegionType.from(string: regionString) {

            let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
            let configuration = AWSServiceConfiguration(region: region, credentialsProvider: credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

extension AWSRegionType {
    static func from(string: String) -> AWSRegionType? {
        switch string.lowercased() {
        case "us-east-1":
            return .USEast1
        case "us-west-2":
            return .USWest2
        case "eu-west-1":
            return .EUWest1
        case "eu-north-1":
            return .EUNorth1
        default:
            return nil
        }
    }
}
