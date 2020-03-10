//
//  DatabaseService.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class DatabaseService {
  
    
    static let  itemsCollection = "items" //collection
    static let usersCollection = "users"
    static let commentsCollection = "comments" //sub-collection on an item document
    //review - firebase works like this
    //top level
    //collection -> document -> collection -> document ->.....
    
    
    //lets get a reference to the fire base fire store database so that we can start writing to it. db means database
    private let db = Firestore.firestore()

    public func createItem(itemName: String, price: Double, category: Category, displayName: String, completion: @escaping (Result<String, Error>) -> ()) {
       //we need the seller ID so we need to get the user ID in order to make it esier to the data so we need a sellers ID and DOcument ID so the data has an ID to make it easier to edit or delete via documwent ID
    
    guard let user = Auth.auth().currentUser else { return }
    //TIME : 10:38 You can create a document by using a generaotr ID , we are saving an item (document) in the firestore
    
    //TIME: 10:42 generate a document id for the items collectiomn. db refernce our database with a unique ID right now it has nothing.
    let documentRef = db.collection(DatabaseService.itemsCollection).document()
    
    //create a document in our "items" collection we are writing to the items colledction, there is a document writing 10:44
   //struct Item {
//     let itemName: String
//     let price: Double
//     let itemId: String
//     let listedDate: Date
//     let sellerName: String
 //     let sellerID: String
//     let categoryName: String
//   }
       //we say database  collection documents. we use a static constant on it , and we created a document reference to us easy to reference the ID
        db.collection(DatabaseService.itemsCollection).document(documentRef.documentID).setData(["itemName":itemName, "price":price, "itemId":documentRef.documentID, "listedDate": Timestamp(date: Date()), "sellerName": displayName, "sellerId": user.uid, "categoryName": category.name]) { (error) in
        //TIME: 10:51am
        //Need to pass in key value paren ts date boolean string are what we cna use. Our property names will be the key we pass in
        if let error = error {
            completion(.failure(error))
          print("error creating item \(error)")
        } else {
            completion(.success(documentRef.documentID))
            print("item was created \(documentRef.documentID)")
        }
    }
    
  }
    public func createDatabaseUser(authDataResult: AuthDataResult, completion: @escaping (Result<Bool, Error>) ->()) {
        //we create a new user we will have a new user items document in that place. It can have whichever you want and it will be in synced with the user ID to the collection
        //TIME: 11:51am V
        guard let email = authDataResult.user.email else {
            return
        }
        db.collection(DatabaseService.usersCollection).document(authDataResult.user.uid).setData(["email" : email, "createdDate": Timestamp(date: Date()), "userId": authDataResult.user.uid]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func updateDatabaseUser(displayName: String, photoURL: String, completion: @escaping (Result<Bool, Error>) -> ()){
        guard let user = Auth.auth().currentUser else { return }
        db.collection(DatabaseService.usersCollection).document(user.uid).updateData(["photoURL": photoURL, "displayName": displayName]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
       }
    public func delete(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        //the document ID happens to be the items id
        db.collection(DatabaseService.itemsCollection).document(item.itemId).delete { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
}
