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
   
    var isRecording: Bool!
    
    var segmentControl: UISegmentedControl!
    var captureButtton: UIButton!
    var recordButton: UIButton!
    var containerView: UIView!
    var recordTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        title = "DJI DRONE"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(red: 61/255, green: 124/255, blue: 180/255, alpha: 1.0)
        
        recordTimeLabel = UILabel()
        recordTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        recordTimeLabel.textColor = .black
        recordTimeLabel.isHidden = true
        
        segmentControl = UISegmentedControl()
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentControl.insertSegment(withTitle: "CaptureMode", at: 0, animated: true)
        segmentControl.insertSegment(withTitle: "RecordMode", at: 1, animated: true)
        segmentControl.addTarget(self, action: #selector(segmentChange), for: .touchUpInside)
        segmentControl.selectedSegmentTintColor = .black
        
        captureButtton = UIButton()
        captureButtton.setTitleColor(.systemBlue, for: .normal)
        captureButtton.setImage(UIImage(named: "camera"), for: .normal)
        captureButtton.addTarget(self, action: #selector(capturePhotos), for: .touchUpInside)
        
        recordButton = UIButton()
        recordButton.setTitleColor(.systemBlue, for: .normal)
        recordButton.setImage(UIImage(named: "video"), for: .normal)
        recordButton.addTarget(self, action: #selector(recordVideo), for: .touchUpInside)
        
        containerView = UIView()
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        
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
        containerView.addSubview(recordTimeLabel)
        
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.65),
            
            recordTimeLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            recordTimeLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 64),
            stackView.topAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         DJISDKManager.registerApp(with: self)
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
        guard let camera = fetchCamera() else {
            return
        }
        
        camera.setMode(DJICameraMode.shootPhoto, withCompletion: {(error) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1){
                camera.startShootPhoto(completion: { (error) in
                    if let _ = error {
                        NSLog("Shoot Photo Error: " + String(describing: error))
                    }
                })
            }
        })
    }
    
    @objc func recordVideo() {
        guard let camera = fetchCamera() else {
            return
        }
        
        if (self.isRecording) {
            camera.stopRecordVideo(completion: { (error) in
                if let _ = error {
                    NSLog("Stop Record Video Error: " + String(describing: error))
                }
            })
        } else {
            camera.startRecordVideo(completion: { (error) in
                if let _ = error {
                    NSLog("Start Record Video Error: " + String(describing: error))
                }
            })
        }
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
    
    @objc func segmentChange() {
        guard let camera = fetchCamera() else {
             return
         }
         
        if (segmentControl.selectedSegmentIndex == 0) {
             camera.setMode(DJICameraMode.shootPhoto,  withCompletion: { (error) in
                 if let _ = error {
                     NSLog("Set ShootPhoto Mode Error: " + String(describing: error))
                 }
             })
             
        } else if (segmentControl.selectedSegmentIndex == 1) {
             camera.setMode(DJICameraMode.recordVideo,  withCompletion: { (error) in
                 if let _ = error {
                     NSLog("Set RecordVideo Mode Error: " + String(describing: error))
                 }
             })
         }
        
    }
    
    func formatSeconds(seconds: UInt) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(seconds))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm:ss"
        return(dateFormatter.string(from: date))
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
    
    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {
        self.isRecording = systemState.isRecording
        self.recordTimeLabel.isHidden = !self.isRecording
        
        self.recordTimeLabel.text = formatSeconds(seconds: systemState.currentVideoRecordingTimeInSeconds)
        
        if (self.isRecording == true) {
            self.recordButton.setTitle("Stop Record", for: .normal)
        } else {
            self.recordButton.setTitle("Start Record", for: .normal)
        }
        
        if (systemState.mode == DJICameraMode.shootPhoto) {
            self.segmentControl.selectedSegmentIndex = 0
        } else {
            self.segmentControl.selectedSegmentIndex = 1
        }
    }
    
}

