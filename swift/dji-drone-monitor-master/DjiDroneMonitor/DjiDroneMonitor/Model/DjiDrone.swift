//
//  DjiDrone.swift
//  DjiDroneMonitor
//
//  Created by Iyin Raphael on 9/22/20.
//  Copyright © 2020 Iyin Raphael. All rights reserved.
//

import Foundation

struct DjiDrone: Codable {
//    let caseID: String
    let lat: Double
    let long: Double
//    let altitude: Double
}

struct ParentData: Codable {
    let result: DjiDrone
}

