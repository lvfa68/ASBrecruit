//
//  NetworkService.swift
//  ASBInterviewExercise
//
//  Created by Lvfa on 03/05/2025.
//

import Foundation
import Combine

// Network error enum
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case unknownError(Error)
    
    var description: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .unknownError(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// Network service protocol
protocol NetworkServiceProtocol {
    func fetchTransactions() -> AnyPublisher<[Transaction], Error>
}

// Network service implementation using RestClient
class NetworkService: NetworkServiceProtocol {
    private let restClient: RestClient
    private let baseURL: URL
    private let jsonDecoder: JSONDecoder
    
    init(baseURLString: String = "https://gist.githubusercontent.com/Josh-Ng/500f2716604dc1e8e2a3c6d31ad01830/raw/4d73acaa7caa1167676445c922835554c5572e82/test-data.json",
         restClient: RestClient = DIManager.shared.resolve(RestClient.self)!) {
        self.restClient = restClient
        guard let url = URL(string: baseURLString) else {
            fatalError("Invalid URL: \(baseURLString)")
        }
        self.baseURL = url
        
        // Configure date decoder
        self.jsonDecoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    func fetchTransactions() -> AnyPublisher<[Transaction], Error> {
        let request = URLRequest(url: baseURL)
        
        return Future<Data, Error> { [weak self] promise in
            guard let self = self else { return promise(.failure(NetworkError.unknownError(NSError()))) }
            
            _ = self.restClient.apiRequest(request) { data, response, error in
                if let error = error {
                    promise(.failure(NetworkError.unknownError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    promise(.failure(NetworkError.invalidResponse))
                    return
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    promise(.failure(NetworkError.httpError(httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    promise(.failure(NetworkError.invalidResponse))
                    return
                }
                
                promise(.success(data))
            }
        }
        .tryMap { data in
            return data
        }
        .decode(type: [Transaction].self, decoder: jsonDecoder)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

// Mock network service for development and testing
class MockNetworkService: NetworkServiceProtocol {
    func fetchTransactions() -> AnyPublisher<[Transaction], Error> {
        return Just(Transaction.sampleData)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
