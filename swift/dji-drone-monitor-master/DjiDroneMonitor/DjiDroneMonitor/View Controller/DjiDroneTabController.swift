//
//  DjiDroneTabController.swift
//  DjiDroneMonitor
//
//  Created by Iyin Raphael on 9/21/20.
//  Copyright © 2020 Iyin Raphael. All rights reserved.
//

import UIKit

class DjiDroneTabController: UITabBarController {
    
    // MARK: - Properties
    let primaryColor = UIColor(red: 228/255, green: 132/255, blue: 74/255, alpha: 1)
    let darkPriColor = UIColor(red: 173/255, green: 86/255, blue: 30/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let djiDroneMissionVC = UINavigationController(rootViewController: DjiDroneMissionViewController())
        let djiDroneVC = UINavigationController(rootViewController: DjiDroneViewController())
        
        djiDroneMissionVC.tabBarItem = UITabBarItem(title: "Mission", image: UIImage(named: "mission"), tag: 0)
        djiDroneVC.tabBarItem = UITabBarItem(title: "Media", image: UIImage(named: "media"), tag: 1)
        djiDroneMissionVC.tabBarItem.selectedImage = UIImage(named: "mission.fill")
        djiDroneVC.tabBarItem.selectedImage = UIImage(named: "media.fill")
    
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .black
        tabBar.barTintColor = primaryColor
        
        
        viewControllers = [ djiDroneMissionVC, djiDroneVC]
        
    }
    

}
