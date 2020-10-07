//
//  DjiDrone.swift
//  DjiDroneMonitor
//
//  Created by Iyin Raphael on 9/22/20.
//  Copyright © 2020 Iyin Raphael. All rights reserved.
//

import Foundation

struct DjiDroneLocation: Codable{
    let caseID: String
    let lat: String
    let long: String
    var image: Data?
//    let altitude: Double
}

class  DjiImage: Codable {
    let caseID: String
    let pictureName: String
    let picture: Data
    
    init(caseID: String, pictureName: String, picture: Data) {
        self.caseID = caseID
        self.pictureName = pictureName
        self.picture = picture
    }
}
