//
//  AppConfig.swift
//  ASBInterviewExercise
//
//  Created by Lvfa on 03/05/2025.
//

import Foundation

// App configuration singleton
class AppConfig {
    static let shared = AppConfig()
    
    // API base URL - uses the real test data on GitHub
    let apiBaseURL = "https://gist.githubusercontent.com/Josh-Ng/500f2716604dc1e8e2a3c6d31ad01830/raw/4d73acaa7caa1167676445c922835554c5572e82/test-data.json"
    
    // Whether to use mock data
    #if DEBUG
    var useMockData: Bool = false  // Set to false to use real API data
    #else
    var useMockData: Bool = false
    #endif
    
    private init() {}
    
    // Get network service instance
    func getNetworkService() -> NetworkServiceProtocol {
        if useMockData {
            return MockNetworkService()
        } else {
            return NetworkService(baseURLString: apiBaseURL)
        }
    }
}
