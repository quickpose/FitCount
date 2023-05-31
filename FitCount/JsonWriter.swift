//
//  JsonWriter.swift
//  FitCount
//
//  Created by QuickPose.ai on 30.05.2023.
//

import Foundation


struct SessionDataModel: Codable, Hashable {
    let exercise: String
    let count: Int
    let seconds: Int
    let date: Date
}


// Function to append data to the existing array in the "userData.json" file
func appendToJson(sessionData: SessionDataModel) {
    print("appendToJson")
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let jsonURL = documentsDirectory.appendingPathComponent("userData.json")
    
    var existingData: [SessionDataModel] = []
    
    // Check if the file exists
    if fileManager.fileExists(atPath: jsonURL.path) {
        do {
            // Read the existing JSON data from the file
            let jsonData = try Data(contentsOf: jsonURL)
            
            // Decode the existing JSON data into an array of SessionDataModel objects
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601 // Set date decoding strategy to ISO 8601 format
            existingData = try decoder.decode([SessionDataModel].self, from: jsonData)
        } catch {
            print("Error reading existing JSON data: \(error.localizedDescription)")
            return
        }
    }
    
    // Append the new session data to the existing array
    existingData.append(sessionData)
    
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601 // Set date encoding strategy to ISO 8601 format
    
    do {
        // Encode the updated array back into JSON data
        let updatedData = try encoder.encode(existingData)
        
        // Write the updated JSON data back to the file
        try updatedData.write(to: jsonURL)
        print("JSON data appended successfully at: \(jsonURL.path)")
    } catch {
        print("Error writing updated JSON data: \(error.localizedDescription)")
    }
}

// Function to load the JSON data and display it in SwiftUI
func loadAndDisplayJsonData() -> [SessionDataModel]? {
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let jsonURL = documentsDirectory.appendingPathComponent("userData.json")
    
    // Check if the file exists
    if fileManager.fileExists(atPath: jsonURL.path) {
        do {
            // Read the JSON data from the file
            let jsonData = try Data(contentsOf: jsonURL)
            
            // Decode the JSON data into an array of SessionDataModel objects
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601 // Set date decoding strategy to ISO 8601 format
            let sessionDataArray = try decoder.decode([SessionDataModel].self, from: jsonData)
            
            return sessionDataArray
        } catch {
            print("Error reading JSON data: \(error.localizedDescription)")
        }
    } else {
        print("JSON file does not exist.")
    }
    
    return nil
}
