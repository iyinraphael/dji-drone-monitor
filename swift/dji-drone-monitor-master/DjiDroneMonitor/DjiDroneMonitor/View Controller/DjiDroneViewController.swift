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
    
    let primaryColor = UIColor(red: 228/255, green: 132/255, blue: 74/255, alpha: 1)
    let secondaryColor = UIColor(red: 30/255, green: 117/255, blue: 173/255, alpha: 1)
   
    let djiDroneController = DjiDroneController()
    var isRecording: Bool!

    var captureButtton: UIButton!
    var recordButton: UIButton!
    var containerView: UIView!
    var recordTimeLabel: UILabel!
    var showImageButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         title = "Dji Drone"
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.barTintColor = primaryColor
        navigationController?.navigationBar.isTranslucent = false
        
        recordTimeLabel = UILabel()
        recordTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        recordTimeLabel.textColor = .black
        recordTimeLabel.isHidden = true
        
        captureButtton = UIButton()
        captureButtton.backgroundColor = secondaryColor
        captureButtton.setImage(UIImage(named: "camera"), for: .normal)
        captureButtton.addTarget(self, action: #selector(capturePhotos), for: .touchUpInside)
    
        recordButton = UIButton()
        recordButton.backgroundColor = secondaryColor
        recordButton.setTitleColor(.systemBlue, for: .normal)
        recordButton.setImage(UIImage(named: "video"), for: .normal)
        recordButton.addTarget(self, action: #selector(recordVideo), for: .touchUpInside)
        
        containerView = UIView()
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        showImageButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showImage))
        navigationItem.rightBarButtonItem = showImageButton
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.addArrangedSubview(captureButtton)
        stackView.addArrangedSubview(recordButton)
    
        view.addSubview(containerView)
        view.addSubview(stackView)
        containerView.addSubview(recordTimeLabel)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 44),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            
            containerView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            containerView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.65),
            
            recordTimeLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            recordTimeLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
        ])
        
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
        
        camera.setMode(DJICameraMode.recordVideo) { error in
            if let _ = error {
                NSLog("Set RecordVideo Mode Error: " + String(describing: error))
            }
            
            if (self.isRecording) {
                camera.stopRecordVideo(completion: { error in
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
    
    
    func formatSeconds(seconds: UInt) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(seconds))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm:ss"
        return(dateFormatter.string(from: date))
    }
    
    @objc func showImage() {
        let vc = DjiDroneImageViewController()
        vc.djiDroneController = djiDroneController
        present(UINavigationController(rootViewController: vc), animated: true)
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
    }
    
}

