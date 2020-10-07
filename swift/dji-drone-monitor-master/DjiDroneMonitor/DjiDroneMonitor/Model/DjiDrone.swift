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
    let CaseID: String
    let PictureName: String
    let Picture: String
    
    init(CaseID: String, PictureName: String, Picture: String) {
        self.CaseID = CaseID
        self.PictureName = PictureName
        self.Picture = Picture
    }
}
