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

struct DjiImage: Codable {
    let CaseID: String
    var PictureInfo: [Info]

    struct Info: Codable {
        let PictureName: String
        let Picture: String
    }
}
