//
//  DJIDroneAnnotation.swift
//  DjiDroneMonitor
//
//  Created by Iyin Raphael on 10/1/20.
//  Copyright © 2020 Iyin Raphael. All rights reserved.
//

import Foundation
import MapKit

final class DJIDroneAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }
}
