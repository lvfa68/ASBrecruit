//
//  RestClient.swift
//  ASBInterviewExercise
//
//  Created by ASB on 29/07/21.
//

import Foundation

class RestClient {
    
    var session: URLSession
    
    init() {
        session = URLSession(configuration: .default)
    }
    
    func apiRequest(_ request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
        
        let sessionTask = session.dataTask(with: request, completionHandler: completionHandler)
        sessionTask.resume()
        return sessionTask
    }
    
    func cancelAllTasks() {
        session.getAllTasks { (tasks) in
            for task in tasks {
                task.cancel()
            }
        }
    }
}
