//
//  StorageService.swift
//  Firebase-Demo
//
//  Created by Melinda Diaz on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseStorage

class StorageService {
    
    //we will be uploading a photo in 2 places 1 in the ProfileVC and the other in CreateItemVC
    //we will create 2 different buckets or folders 1. User profilePhotos/ 2. ItemsPhotos/
    //The way we will be saving the photos in the buckets so we need to go buy the user ID. so for instance ItemPhotos/itemId
    //lets create a reference to the firebase storage if you are going to write to that storage you need an instance
    private let storageRef = Storage.storage().reference()//we need the reference part
    //default parameters in Swift ex: userId: String? = nil
    public func updatePhoto(userId: String? = nil, itemId: String? = nil, image: UIImage, completion: @escaping (Result<URL, Error>) -> ()){
        //TIME:11:33am III. So we get an image from the user and we will resize that image and then presenting and then convert the image to data then pass the data over to the firebase function and uploads the data to the firebase storage then we get back a downloaded url then we attach the download file to the userID profile photo
        //step1: Convert the UIImage to data because this is the object we are posting to firebase storage
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return
        }
        //step2: we need to establish which bucket or collection or folder we will be saving the photo to
        var photoReference: StorageReference!
        if let userId = itemId { //coming from CreateItemViewController
            photoReference = storageRef.child("UserProfilePhotos/\(userId).jpg")// its basically an append and in the top folder i want to create a subfolder or Child folder to that reference, we can do functions on the folder such as delete but you MUST have the ID in order to do it
        } else if let itemId = itemId {
            photoReference = storageRef.child("ItemsPhoto/\(itemId).jpg")
        }
        //configure MeteData for the object being uploaded. metadata is a container for different attributes of that object so in this case is what type of data we are sending up to firebase
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        //Based on the reference ewe created it is either the item photos or profile photos at this point we convert our image to data//TIME: 11:48 III or 10:33am IV
        //TODO: Thread 1: Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value
        let _ = photoReference.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            } else if let _ = metadata {
                //the download function gets the url of that function and gives the location of the photo and associated it with the user photo to the url
                photoReference.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url))
                        //we have a local image so we take that local image an dconvert it to data and we have metadat. we could have a error if not we have meteada, on the download url has a completion handler if i have an error i sentback to the VC a=with an error if we ar successful then we get a photo and attach it to the item of profile pic.//TIME: 11:53
                    }
                }
            }
        }
    }
}
