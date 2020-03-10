//
//  CreateItemViewController.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore //takes care of database firestore

class CreateItemViewController: UIViewController {
    
    
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemPriceTextField: UITextField!
    
    private var category: Category
    private let dbService = DatabaseService()
    private let storageService = StorageService()
    
    private lazy var imagePickerController: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self //conform to UIImagePickerController and UINavigationControllerDelegate
        return picker
    }()
    
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.addTarget(self , action: #selector(showPhotoOption))
        return gesture
    }()
    
    private var selectedImage: UIImage? {
        didSet{
            itemImageView.image = selectedImage
        }
    }
    
    init?(coder: NSCoder, category: Category) {
        self.category = category
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = category.name
        itemImageView.isUserInteractionEnabled = true
        itemImageView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func showPhotoOption() {
        let alertController = UIAlertController(title: "Choose Photo Option", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { alertAction in
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true)
        }
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { alertAction in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            alertController.addAction(cameraAction)
        }
        alertController.addAction(photoLibrary)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    
    @IBAction func sellButtonPressed(_ sender: UIBarButtonItem) {
        guard let itemName = itemNameTextField.text,
            !itemName.isEmpty,
            let priceText = itemPriceTextField.text,
            !priceText.isEmpty,
            //converting price text to a double
            let price = Double(priceText),
            let selectedImage = selectedImage else {
                showAlert(title: "Missing Fields", message: "ALL Fields are required along with a photo")
                return
        }
        //TODO: Fix the picture(selected Image)
        guard let displayName = Auth.auth().currentUser?.displayName else {
            showAlert(title: "Incomplete Profile", message: "Please complete your profile")
            return
        }
        let resizedImage = UIImage.resizeImage(originalImage: selectedImage, rect: itemImageView.bounds)
        dbService.createItem(itemName: itemName, price: price, category: category, displayName: displayName ) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error creating item", message: "Sorry something went wrong: \(error.localizedDescription)")
                }
            case .success(let documentId):
                self?.uploadPhoto(photo: resizedImage, documentId: documentId)
                self?.showAlert(title: nil, message: "Successfully listed your item")
                
            }
        }
        // dismiss(animated: true, completion: nil)
    }
    
    private func uploadPhoto(photo: UIImage, documentId: String) {
        storageService.updatePhoto(itemId: documentId, image: photo) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error uploading photo", message: "\(error.localizedDescription)")
                }
            case .success(let url):
                self?.updateItemImageURL(url, documentId: documentId)
            }
        }
    }
    
    private func updateItemImageURL(_ url: URL, documentId: String){
        //update an existing document on firebase
        Firestore.firestore().collection(DatabaseService.itemsCollection).document(documentId).updateData(["imageURL" : url.absoluteString]) { [weak self] (error) in
            //you can create a key or add an existing key //TIME: 12:02pm IV
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Fail to update Item", message: "\(error.localizedDescription)")
                }
            } else {
                //Everything went ok
                print("all went well with the update")
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            }
        }
    }
}

extension CreateItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("could not attain original image")
        }
        selectedImage = image
        dismiss(animated: true)
    }
}
