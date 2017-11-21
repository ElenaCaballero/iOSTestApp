//
//  ShowUserProfileTableViewController.swift
//  KaisApp
//
//  Created by Elena Caballero on 11/17/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import Firebase
import FirebaseAuth
import FirebaseAuthUI
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit

class ShowUserProfileTableViewController: UITableViewController {
    
    var rightBarButtonItem: UIBarButtonItem!
    
    var activityIndicatorView: UIActivityIndicatorView!
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    
    var uid:String = String()
    var snapshots = [DataSnapshot]()
    var imagesSnapshots = [DataSnapshot]()
    var userSnapshot = [DataSnapshot]()
    var users = DataSnapshot()

    @IBOutlet var showUserProfileTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.color = UIColor.black
        
        showUserProfileTableView.backgroundView = activityIndicatorView
        
        self.hideKeyboardWhenTappedAround()
        
        showUserProfileTableView.register(UINib.init(nibName: "MainDetailHeader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "MainDetailHeaderID")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = UIColor(rgb: 0x2390D4)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        if snapshots.isEmpty {
            activityIndicatorView.startAnimating()
            
            dispatchQueue.async {
                self.showUserProfileTableView.separatorStyle = .none
                
                Thread.sleep(forTimeInterval: 3)
                
                OperationQueue.main.addOperation() {
                    self.showUserProfileTableView.separatorStyle = .singleLine
                    
                    self.loadImageContentForCells()
                    self.loadUserContent()
                }
            }
            
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            var countSnapshots = 0
            if snapshots.count > 0 {
                TableViewHelper.EmptyMessage(message: "", viewController: self)
                for snap in snapshots{
                    let thing = snap.value as? Dictionary<String, AnyObject>
                    let userID = thing!["uid"] as! String
                    if uid.caseInsensitiveCompare(userID) == ComparisonResult.orderedSame {
                        imagesSnapshots.append(snap)
                        countSnapshots += 1
                    }
                }
                return countSnapshots
            }else {
                TableViewHelper.EmptyMessage(message: "Aún no hay fotografías,\n agrega una y muestra la magia de tus viajes.", viewController: self)
                return 0
            }
        default:
            assert(false, "section \(section)")
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300
        }
        return 200
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.showUserProfileTableView.dequeueReusableHeaderFooterView(withIdentifier: "MainDetailHeaderID")
        if let mainDetailHeader = header as? MainDetailHeader{
            mainDetailHeader.setupSegmentedControl()
        }
        return header
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (indexPath.section == 1) {
            return indexPath;
        }
        return nil;
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.section == 1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userInfo", for: indexPath) as! UserProfileTableViewCell
            
            for user in userSnapshot {
                let userID = user.key
                print(uid)
                if uid.caseInsensitiveCompare(userID) == ComparisonResult.orderedSame {
                    users = user
                }
            }
            
            if userSnapshot.count > 0 {
                cell.forStaticCell(userId: uid, users: users, storageHero: storageHero, storageProfile: storageProfile)
            }else {
                cell.emptyStaticCell()
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "imagesArea", for: indexPath) as! UserProfileTableViewCell
        
        if imagesSnapshots.count > 0 {
            print("ImagesSnapshots greater than 0")
            if indexPath.row >= imagesSnapshots.count {
                print("ImagesSnapshots less than indexpath")
                cell.backgroundColor = UIColor.black
                cell.emptyDynamicCell()
            }else {
                print("ImagesSnapshots greater than indexpath")
                cell.imagesSnapshot = imagesSnapshots[indexPath.row]
                cell.forDynamicCells(snapshot: imagesSnapshots[indexPath.row], storage: storage)
            }
        }else {
            print("ImagesSnapshots less than 0")
            cell.emptyDynamicCell()
        }
        
        return cell
    }

    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowImagesDetailViewUsers", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowImagesDetailViewUsers" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationViewController = segue.destination as! ImagesDetailViewController
                destinationViewController.snap = snapshots[indexPath.row]
                destinationViewController.storage = Storage.storage().reference(forURL: "gs://kaisapp-dev.appspot.com/images")
            }
        }
    }
    
    //MARK: - Database Connection
    
    var ref: DatabaseReference!
    var storage: StorageReference!
    var storageHero: StorageReference!
    var storageProfile: StorageReference!
    
    func loadImageContentForCells(){
        ref = Database.database().reference(fromURL: "https://kaisapp-dev.firebaseio.com").child("images_data")
        storage = Storage.storage().reference(forURL: "gs://kaisapp-dev.appspot.com/images")
        
        ref.queryOrdered(byChild: "timestamp").observe(.value) { [weak self] (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                self?.snapshots = snapshots
                self?.activityIndicatorView.stopAnimating()
                self?.showUserProfileTableView.reloadSections(IndexSet.init(integer: 1), with: UITableViewRowAnimation.none)
            }
        }
    }
    
    func loadUserContent(){
        ref = Database.database().reference(fromURL: "https://kaisapp-dev.firebaseio.com").child("users")
        storageHero = Storage.storage().reference(forURL: "gs://kaisapp-dev.appspot.com/heros")
        storageProfile = Storage.storage().reference(forURL: "gs://kaisapp-dev.appspot.com/profiles")
        
        ref.queryOrderedByKey().observe(.value) { [weak self] (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                self?.userSnapshot = snapshots
                self?.showUserProfileTableView.reloadSections(IndexSet.init(integer: 0), with: UITableViewRowAnimation.none)
            }
        }
    }

}
