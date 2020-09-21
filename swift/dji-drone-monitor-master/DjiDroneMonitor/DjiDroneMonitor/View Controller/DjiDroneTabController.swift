//
//  DjiDroneTabController.swift
//  DjiDroneMonitor
//
//  Created by Iyin Raphael on 9/21/20.
//  Copyright © 2020 Iyin Raphael. All rights reserved.
//

import UIKit

class DjiDroneTabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DJI Drone"
        let djiDroneMissionVC = DjiDroneMissionViewController()
        let djiDroneVC = DjiDroneViewController()
        
        djiDroneMissionVC.tabBarItem = UITabBarItem(title: "Mission", image: nil, tag: 0)
        djiDroneVC.tabBarItem = UITabBarItem(title: "Media", image: nil, tag: 1)

        viewControllers = [ djiDroneMissionVC, djiDroneVC]
    }
    

}
