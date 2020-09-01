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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let camera = fetchCamera(), let delegate = camera.delegate, delegate.isEqual(self) {
            camera.delegate = nil
        }
        
        self.resetVideoPreview()
    }
    
    
    // MARK: - Methods
        
    @objc func capturePhotos() {
        
    }
    
    @objc func recordVideo() {
        
    }
    
    func setupVideoPreviewer() {
        DJIVideoPreviewer.instance().setView(self.containerView)
        let product = DJISDKManager.product()
        
        //Use "SecondaryVideoFeed" if the DJI Product is A3, N3, Matrice 600, or Matrice 600 Pro, otherwise, use "primaryVideoFeed".
        if ((product?.model == DJIAircraftModelNameA3)
            || (product?.model == DJIAircraftModelNameN3)
            || (product?.model == DJIAircraftModelNameMatrice600)
            || (product?.model == DJIAircraftModelNameMatrice600Pro)) {
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.add(self, with: nil)
        } else {
            DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
        }
        DJIVideoPreviewer.instance().start()
    }
    
    func resetVideoPreview() {
        DJIVideoPreviewer.instance().unSetView()
        let product = DJISDKManager.product()
        
        //Use "SecondaryVideoFeed" if the DJI Product is A3, N3, Matrice 600, or Matrice 600 Pro, otherwise, use "primaryVideoFeed".
        if ((product?.model == DJIAircraftModelNameA3)
            || (product?.model == DJIAircraftModelNameN3)
            || (product?.model == DJIAircraftModelNameMatrice600)
            || (product?.model == DJIAircraftModelNameMatrice600Pro)) {
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.remove(self)
        } else {
            DJISDKManager.videoFeeder()?.primaryVideoFeed.remove(self)
        }
    }
    
    func fetchCamera() -> DJICamera? {
        guard let product = DJISDKManager.product() else {
            return nil
        }
        if product is DJIAircraft {
            return (product as! DJIAircraft).camera
        }
        if product is DJIHandheld {
            return (product as! DJIHandheld).camera
        }
        return nil
    }
    
    func showAlertViewWithTitle(title: String, withMessage message: String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title:"OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}


    // MARK: - DJIVideoFeedListner

extension DjiDroneViewController: DJIVideoFeedListener {
    
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData videoData: Data) {
        let videoData = videoData as NSData
        let videoBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: videoData.length)
        videoData.getBytes(videoBuffer, length: videoData.length)
        DJIVideoPreviewer.instance().push(videoBuffer, length: Int32(videoData.length))
    }
    
}


    // MARK: - DJISDKManagerDelegate

extension DjiDroneViewController: DJISDKManagerDelegate {
    
    func productConnected(_ product: DJIBaseProduct?) {
        NSLog("Product Connected")
        
        if let camera = fetchCamera() {
            camera.delegate = self
        }
        self.setupVideoPreviewer()
        
        DJISDKManager.userAccountManager().logIntoDJIUserAccount(withAuthorizationRequired: false) { (state, error) in
            if let _ = error {
                NSLog("Login failed: %@" + String(describing: error))
            }
        }
    }
    
    func productDisconnected() {
        NSLog("Product Disconnected")

        if let camera = fetchCamera(), let delegate = camera.delegate, delegate.isEqual(self) {
            camera.delegate = nil
        }
        self.resetVideoPreview()
    }
    
    func appRegisteredWithError(_ error: Error?) {
        var message = "Register App Successed!"
        if let _ = error {
            message = "Register app failed! Please enter your app key and check the network."
        } else {
            DJISDKManager.startConnectionToProduct()
        }
        
        self.showAlertViewWithTitle(title:"Register App", withMessage: message)
    }
    
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
         NSLog("Download database : \n%lld/%lld", progress.completedUnitCount, progress.totalUnitCount)
    }
    
    
}

    // MARK: -  DJICameraDelegate

extension DjiDroneViewController:  DJICameraDelegate {
    
}

