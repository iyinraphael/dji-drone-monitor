//
//  AppDelegate.swift
//  DjiDroneMonitor
//
//  Created by Iyin Raphael on 9/1/20.
//  Copyright © 2020 Iyin Raphael. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let nav = UINavigationController()
        let vc =  DjiDroneTabController()
        
        nav.addChild(vc)
        nav.view.frame = vc.view.bounds
        
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        return true
    }


}

