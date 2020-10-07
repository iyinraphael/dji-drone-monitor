//
//  DjiDroneImageViewController.swift
//  DjiDroneMonitor
//
//  Created by Iyin Raphael on 10/6/20.
//  Copyright © 2020 Iyin Raphael. All rights reserved.
//

import UIKit

class DjiDroneImageViewController: UIViewController {

    // MARK: - Properties
    
    let primaryColor = UIColor(red: 228/255, green: 132/255, blue: 74/255, alpha: 1)
    let secondaryColor = UIColor(red: 30/255, green: 117/255, blue: 173/255, alpha: 1)
    
    var addImageBarbutton: UIBarButtonItem!
    var imagePickerController: UIImagePickerController!
    var imageView: UIImageView!
    var caseIDTextField: UITextField!
    var submitButton: UIButton!
    
    var djiDroneLocation: DjiDroneLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = primaryColor
        navigationController?.navigationBar.isTranslucent = false
        
        addImageBarbutton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addImage))
        navigationItem.rightBarButtonItem = addImageBarbutton
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 5.0
        view.addSubview(stackView)
        
        caseIDTextField = UITextField()
        caseIDTextField.delegate = self
        caseIDTextField.placeholder = "Enter case ID"
        caseIDTextField.layer.borderWidth = 0.2
        caseIDTextField.layer.borderColor = secondaryColor.cgColor
        stackView.addArrangedSubview(caseIDTextField)
        
        submitButton = UIButton()
        submitButton.setTitle("Submit", for: .normal)
        submitButton.backgroundColor = secondaryColor
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        stackView.addArrangedSubview(submitButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            caseIDTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Methods
    
    @objc func addImage() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("The photo library is Unavailable")
            return
        }
        
        imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        
        present(imagePickerController, animated: true)
    
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }


}

extension DjiDroneImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)

        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
            self.djiDroneLocation = DjiDroneLocation(caseID: "Case123", lat: "0", long: "0", image: jpegData)
            
            guard let imageData = djiDroneLocation?.image,
                let image = UIImage(data: imageData) else { return }
            
            imageView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerController.dismiss(animated: true, completion: nil)
    }
}

extension DjiDroneImageViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.becomeFirstResponder()
        textField. 
    }
}
