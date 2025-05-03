//
//  DIManager.swift
//  ASBInterviewExercise
//
//  Created by ASB on 29/07/21.
//

import Foundation
import Swinject

class DIManager {
    static let shared = DIManager()
    
    var assembler: Assembler
    
    init() {
        let assembler = Assembler([ServiceAssembly()])
        self.assembler = assembler
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        return assembler.resolver.resolve(type)
    }
}

class ServiceAssembly: Assembly {
    func assemble(container: Container) {
        // Register original RestClient
        container.register(RestClient.self) { resolver in
            return RestClient()
        }.inObjectScope(.transient)
        
        // Register NetworkService
        container.register(NetworkServiceProtocol.self) { resolver in
            let restClient = resolver.resolve(RestClient.self)!
            return NetworkService(
                baseURLString: AppConfig.shared.apiBaseURL,
                restClient: restClient
            )
        }.inObjectScope(.container)
        
        // Register TransactionViewModel
        container.register(TransactionViewModel.self) { resolver in
            let networkService = resolver.resolve(NetworkServiceProtocol.self)!
            return TransactionViewModel(networkService: networkService)
        }.inObjectScope(.container)
    }
}

