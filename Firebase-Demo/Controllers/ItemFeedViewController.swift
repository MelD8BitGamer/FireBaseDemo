//
//  ItemFeedViewController.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
//TODO: Have a signout and a custom Zib file for the custom cell ot will be slacked out

class ItemFeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    //It register an dobserfve tochanges in FIrebase so we give them an object and if we sont want to use it we remove the listen and they are assoiciated with fire store
    private var listener: ListenerRegistration?
    
    private var items = [Item]() {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private let databaseService = DatabaseService()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //TIME: 11:52am
        listener = Firestore.firestore().collection(DatabaseService.itemsCollection).addSnapshotListener({ [weak self] (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Firestore error Try again later", message: "\(error.localizedDescription)")
                }
                //snapshot is equivalent to the snapshot data
            } else if let snapshot = snapshot {
            //TIME: 11:58am we need the dictionary to create a diction ary initializer and use it here so ther is no encoding or decoding going on there
                //we are after the data of the document so map goes through each item in the array it takes in a dictionary and passes the data causde data is a dictionary
                //TIME:12:14
                let items = snapshot.documents.map {Item($0.data())}
                self?.items = items
                print("there are \(snapshot.documents.count) items for sale")
            }
        })
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        listener?.remove()
    }
}
extension ItemFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell else{
            fatalError("could not downcast to itemCell")
        }
        let item = items[indexPath.row]
        cell.configureCell(for: item)
        return cell
    }
    //to delete a user but we need conditions
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
         //perform deletion
            let item = items[indexPath.row]
            databaseService.delete(item: item) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Deletion Error", message: error.localizedDescription)
                    }
                case .success:
                    print("deleted sucessfully")
                    //TODO: show alert!!
                }
            }
        }
    }
    //on the client side meaning the app we will ensure that swipe to delete only works for the user but that is not enough to prevent sccidental deleteion from the client we need to protect the database as well, we will do so using Firebase "Security Rules"
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let item = items[indexPath.row]
        guard let user = Auth.auth().currentUser else { return false }
        //the seller ID is the same as the user ID and we want to validate that
        if item.sellerID != user.uid {
            return false //cannot swipe on row to delete
        }
        return true //able to swipe to delete items
    }
    //remember if ther eis an android user they CAN STILL delete items of another user so you have to be able to delete it on the Firestore database itself
}
extension ItemFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 140
    }

}
