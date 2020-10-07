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
    let pictureURL = URL(string: "http://52.179.114.126/prweb/PRRestService/PictureDrone/v1/Picture")!
    typealias completionHandler = ([DjiDroneLocation?], Result<Bool, NetworkError> ) -> Void
    
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
                let DjiDroneLocations = try Array( JSONDecoder().decode([String : DjiDroneLocation].self, from: data).values)
                completion(DjiDroneLocations, .success(true))
            } catch {
                NSLog("Error decoding data: \(error)")
                completion([nil], .failure(.failedDecode))
            }
        }
        taskSession.resume()
    }
    
    func sendImage(_ djiImage: DjiImage, with completion: @escaping completionHandler = { _, _ in  }) {
        var urlRequest = URLRequest(url: pictureURL)
        urlRequest.httpMethod = Rest.post.rawValue
        
        do {
            let jsonEncoder =  JSONEncoder()
            let djiImageJson = try jsonEncoder.encode(djiImage)
            urlRequest.httpBody = djiImageJson
        } catch {
            NSLog("Error encoding data: \(error)")
            completion([nil], .failure(.failedEncode))
        }
        
        let taskSession = URLSession.shared.dataTask(with: urlRequest) { _, response, error in
            if let error = error {
                NSLog("Network error occur: \(error)")
                completion([nil], .failure(.otherError))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    print("Status 200!")
                    return
                } else {
                    print("\(response.statusCode)")
                }
            }
            completion([nil], .success(true))
        }
        taskSession.resume()
    }
}
