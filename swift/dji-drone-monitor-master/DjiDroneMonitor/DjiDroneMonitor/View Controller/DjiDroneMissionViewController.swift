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
    var djiDronesLocations = [CLLocationCoordinate2D]()
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
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: reuseIdentifier)
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

    }
    
    private func showDiffLocation() {
        djiDroneController.getLocationData { djiDroneLocations, result in
            if result == .success(true) {
                self.annotation = MKPointAnnotation()
                for coordinate in djiDroneLocations {
                    guard let location =  coordinate,
                    let lat = Double(location.lat),
                    let long =  Double(location.long) else { return }
                    
                    let cLlocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    self.djiDronesLocations.append(cLlocation)
                    
                    self.annotation?.title = coordinate?.caseID
                    self.annotation?.coordinate =  cLlocation
                    
                    DispatchQueue.main.async {
                        self.mapView.addAnnotation(self.annotation!)
                        
                        let span = MKCoordinateSpan(latitudeDelta:95.7129,
                                                    longitudeDelta:  37.0902)
                        let region = MKCoordinateRegion(center: self.djiDronesLocations[0], span: span)
                        self.mapView.setRegion(region, animated: true)
                    }
                    
                }
            }
        }
    }
}


extension DjiDroneMissionViewController: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
        
       if annotationView == nil {
              annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
              annotationView!.canShowCallout = true
          } else {
              annotationView!.annotation = annotation
          }
        return annotationView
    }
    
}
