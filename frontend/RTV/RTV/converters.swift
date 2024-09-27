//
//  converters.swift
//  RTV
//
//  Created by Luka Andrensek on 25. 9. 24.
//

import Foundation

func convertToJSONStringDictionary(from jsonString: String) -> [String: String]? {
    // Convert the string to Data
    guard let jsonData = jsonString.data(using: .utf8) else {
        print("Failed to convert string to Data")
        return nil
    }
    
    // Decode the JSON data into a [String: String] dictionary
    do {
        let jsonDictionary = try JSONDecoder().decode([String: String].self, from: jsonData)
        return jsonDictionary
    } catch {
        print("Failed to decode JSON: \(error.localizedDescription)")
        return nil
    }
}
