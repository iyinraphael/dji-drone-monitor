//
//  DjiDroneController.swift
//  DjiDroneMonitor
//
//  Created by Iyin Raphael on 9/22/20.
//  Copyright © 2020 Iyin Raphael. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case noIdentifier
    case otherError
    case noData
    case failedDecode
    case failedEncode
}

enum Rest: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

class DjiDroneController {
    
    // MARK: - Properties
    let url = URL(string: "https://drone-app-c74c3.firebaseio.com/")!
    typealias completionHandler = ([DjiDrone?], Result<Bool, NetworkError> ) -> Void
    var arrayDjiDrone: [DjiDrone] = []
    
    // MARK: - Method
    
    func getLocationData(with completion: @escaping completionHandler = { _, _ in }) {
        let urlRequest = url.appendingPathExtension("json")
        var request = URLRequest(url: urlRequest)
        request.httpMethod = Rest.get.rawValue
        
        let taskSession = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                NSLog("Network error occur: \(error)")
                completion([nil], .failure(.otherError))
                return
            }
            
            guard let data = data else {
                NSLog("No data response from server")
                completion([nil], .failure(.noData))
                return
            }
            
            do {
                let parentData =  try JSONDecoder().decode(ParentData.self, from: data)
                self.arrayDjiDrone = [parentData.result]
            } catch {
                NSLog("Error decoding data: \(error)")
                completion([nil], .failure(.failedDecode))
            }
            completion(self.arrayDjiDrone, .success(true))
        }
                               
        taskSession.resume()
        
    }
}
