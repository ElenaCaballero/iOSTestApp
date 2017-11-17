//
//  ImagesTableViewController.swift
//  KaisApp
//
//  Created by Elena on 11/2/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class ImagesTableViewController: UITableViewController {
    
    var ref: DatabaseReference!
    var storage: StorageReference!
    
    @IBOutlet var imagesTableView: UITableView!
    
    var data = Images_Data()
    var snapshots = [DataSnapshot]()
    
    var activityIndicatorView: UIActivityIndicatorView!
    
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.color = UIColor.black
        
        imagesTableView.backgroundView = activityIndicatorView

        imagesTableView.rowHeight = 200.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(rgb: 0x2390D4)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        tabBarController?.tabBar.barTintColor = UIColor(rgb: 0x2390D4)
        tabBarController?.tabBar.tintColor = UIColor(rgb: 0xff9510)
        
        if snapshots.isEmpty {
            activityIndicatorView.startAnimating()
            
            dispatchQueue.async {
                self.imagesTableView.separatorStyle = .none
                
                Thread.sleep(forTimeInterval: 5)
                
                OperationQueue.main.addOperation() {
                    self.imagesTableView.separatorStyle = .singleLine
                    
                    self.loadContentForCells()
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return snapshots.isEmpty ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapshots.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImagesImageTableCell", for: indexPath) as? MainTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ImagesTableViewCell.")
        }
        
        cell.imagesPlaces(snap: snapshots[indexPath.row], storage: storage)
        
        return cell
    }
    
    //MARK: Navigation to Images Detail View
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowImagesDetailView", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "ShowImagesDetailView" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationViewController = segue.destination as! ImagesDetailViewController
                destinationViewController.snap = snapshots[indexPath.row]
                destinationViewController.storage = Storage.storage().reference(forURL: "gs://kaisapp-dev.appspot.com/images")
            }
        }
        
        if segue.identifier == "showUserView" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationViewController = segue.destination as! UserProfileTableViewController
                let thing = snapshots[indexPath.row].value as? Dictionary<String, AnyObject>
                let uid = (thing!["uid"]  as! String)
                destinationViewController.uid = uid
            }
        }
    }

    //MARK: Tabs Initializer
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Initialize Tab Bar Item
        tabBarItem = UITabBarItem(title: "Explorar", image: UIImage(named: "explore"), tag: 1)
    }
    
    //MARK: Database Connection
    
    func loadContentForCells(){
        ref = Database.database().reference(fromURL: "https://kaisapp-dev.firebaseio.com").child("images_data")
        storage = Storage.storage().reference(forURL: "gs://kaisapp-dev.appspot.com/images")
        
        ref.queryOrdered(byChild: "timestamp").observe(.value) { [weak self] (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                self?.snapshots = snapshots
                self?.activityIndicatorView.stopAnimating()
                self?.imagesTableView.reloadData()
            }
        }
    }

}
