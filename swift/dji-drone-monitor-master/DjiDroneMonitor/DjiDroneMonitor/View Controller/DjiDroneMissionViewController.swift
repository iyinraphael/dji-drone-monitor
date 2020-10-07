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
import MapKit

class DjiDroneMissionViewController: UIViewController {

    // MARK: - Properties
    let primaryColor = UIColor(red: 228/255, green: 132/255, blue: 74/255, alpha: 1)
    var djiDroneController: DjiDroneController?
    var djiDronesAnnotations = [DJIDroneAnnotation]()
    var locationManager: CLLocationManager?
    var location: CLLocationCoordinate2D?
    let reuseIdentifier = "viewPoint"
    
    var mapView: MKMapView!
    var barButton: UIBarButtonItem!
    var annotationView: MKAnnotationView!
    var annotation: MKPointAnnotation?
    
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
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: reuseIdentifier)
        view.addSubview(mapView)
        
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
        
        showDiffLocation()
    }
    
    // MARK: - Methods
    
    @objc func showLocation() {
      
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        handleAuthorization(for: locationManager!, status: CLLocationManager.authorizationStatus())

    }
    
    private func handleAuthorization(for locationManager: CLLocationManager, status: CLAuthorizationStatus) {
        
        switch status {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            showAlertView(for: "Resticted", with: "User's location access is restricted")
        case .denied:
            showAlertView(for: "Denied", with: "User Denied Location access")
        case .authorizedAlways:
            guard let center =  locationManager.location?.coordinate else { return }
            centerView(center: center)
        case .authorizedWhenInUse:
            guard let center = locationManager.location?.coordinate else { return }
            centerView(center: center)
        @unknown default:
            fatalError()
        }
    }
    
    private func showAlertView(for title: String, with message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(action)
        
        self.present(alertController, animated: true)
    }
    
    private func centerView(center: CLLocationCoordinate2D) {
        let locationDistance: Double = 500
        let region = MKCoordinateRegion(center: center,
                                        latitudinalMeters: locationDistance,
                                        longitudinalMeters: locationDistance)
        mapView.setRegion(region, animated: true)
    }
    
    private func showDiffLocation() {
        
        djiDroneController?.getLocationData { djiDroneLocations, result in
            if result == .success(true) {
                for djiDroneLocation in djiDroneLocations {
                    guard let location =  djiDroneLocation,
                    let lat = Double(location.lat),
                    let long =  Double(location.long) else { return }
                    
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let djiDroneAnnotation = DJIDroneAnnotation(coordinate: coordinate, title: location.caseID, subtitle: "Location for case ID: \(location.caseID)")
                    
                    self.djiDronesAnnotations.append(djiDroneAnnotation)
                    
                    DispatchQueue.main.async {
                        self.mapView.addAnnotation(djiDroneAnnotation)
                    }
                    
                }
//                let span = MKCoordinateSpan(latitudeDelta:0.05,
//                                            longitudeDelta:  0.05)
//                let region = MKCoordinateRegion(center: self.djiDronesLocations[0], span: span)
//                self.mapView.setRegion(region, animated: true)
            }
        }
    }
}


extension DjiDroneMissionViewController: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let djiAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKMarkerAnnotationView {
            djiAnnotationView.animatesWhenAdded = true
            djiAnnotationView.titleVisibility = .adaptive
            djiAnnotationView.subtitleVisibility = .adaptive
            djiAnnotationView.markerTintColor = primaryColor
            djiAnnotationView.glyphImage = UIImage(named: "mission")
            
            return djiAnnotationView
            
        }
        return nil
    }
    
}

extension DjiDroneMissionViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let center = location.coordinate
            centerView(center: center)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if let locationManager = locationManager {
           handleAuthorization(for: locationManager, status: status)
        }
    }
}
