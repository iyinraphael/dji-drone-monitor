//
//  DjiDroneMissionViewController.swift
//  DjiDroneMonitor
//
//  Created by Iyin Raphael on 9/21/20.
//  Copyright © 2020 Iyin Raphael. All rights reserved.
//

import UIKit
import DJISDK
import DJIUXSDK
import DJIWidget

class DjiDroneMissionViewController: UIViewController {

    // MARK: - Properties
    let primaryColor = UIColor(red: 228/255, green: 132/255, blue: 74/255, alpha: 1)
    let djiDroneController = DjiDroneController()
    var djiDronesLocations = [DjiDroneLocation]()
    
    var mapView: MKMapView!
    var barButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Dji Drone"
        
        navigationController?.navigationBar.barTintColor = primaryColor
        navigationController?.navigationBar.isTranslucent = false
        
        barButton = UIBarButtonItem()
        barButton.image = UIImage(systemName: "location.fill")
        barButton.target = self
        barButton.action = #selector(showLocation)
        barButton.tintColor = .black
        navigationItem.rightBarButtonItem = barButton
        
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Methods
    
    @objc func showLocation() {
        djiDroneController.getLocationData { djiDroneLocations, result in
            if result == .success(true) {
                for location in djiDroneLocations {
                    guard let location =  location else { return }
                    self.djiDronesLocations.append(location)
                }
            }
            
        }
    }
    
}


extension DjiDroneMissionViewController: MKMapViewDelegate {
    
}
