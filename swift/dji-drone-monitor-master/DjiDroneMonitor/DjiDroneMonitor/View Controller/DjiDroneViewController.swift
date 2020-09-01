//
//  DjiDroneViewController.swift
//  DjiDroneMonitor
//
//  Created by Iyin Raphael on 9/1/20.
//  Copyright © 2020 Iyin Raphael. All rights reserved.
//

import UIKit
import DJIWidget
import DJISDK

class DjiDroneViewController: UIViewController {

    // MARK: - Properties
   
    var segmentControl: UISegmentedControl!
    var captureButtton: UIButton!
    var recordButton: UIButton!
    var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "DJI Drone"
        navigationController?.navigationBar.barTintColor = .gray
        
        segmentControl = UISegmentedControl()
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.insertSegment(withTitle: "CaptureMode", at: 0, animated: true)
        segmentControl.insertSegment(withTitle: "RecordMode", at: 1, animated: true)
        segmentControl.backgroundColor = .gray
        segmentControl.selectedSegmentTintColor = .systemBlue
        
        captureButtton = UIButton()
        captureButtton.setTitle("Capture", for: .normal)
        captureButtton.setTitleColor(.systemBlue, for: .normal)
        captureButtton.addTarget(self, action: #selector(capturePhotos), for: .touchUpInside)
        
        recordButton = UIButton()
        recordButton.setTitle("Record", for: .normal)
        recordButton.setTitleColor(.systemBlue, for: .normal)
        recordButton.addTarget(self, action: #selector(recordVideo), for: .touchUpInside)
        
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.addArrangedSubview(captureButtton)
        stackView.addArrangedSubview(recordButton)
        
        view.addSubview(segmentControl)
        view.addSubview(containerView)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    // MARK: - Methods
        
        @objc func capturePhotos() {

    }
    
    @objc func recordVideo() {
        
    }

}
    
