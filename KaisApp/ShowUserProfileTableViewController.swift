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
        
        self.hideKeyboardWhenTappedAround()
        
        if showUserProfileTableView != nil {
            showUserProfileTableView.addSubview(activityIndicatorView)
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorView.hidesWhenStopped = true
            activityIndicatorView.color = UIColor.black
            let horizontalConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            showUserProfileTableView.addConstraint(horizontalConstraint)
            let verticalConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
            showUserProfileTableView.addConstraint(verticalConstraint)
        
            showUserProfileTableView.register(UINib.init(nibName: "MainDetailHeader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "MainDetailHeaderID")
        }
        
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
                    self.checkIfFollowing()
                }
            }
        }
        
    }
    
    func checkIfFollowing() {
        ref = Database.database().reference(fromURL: "https://kaisapp-dev.firebaseio.com")
        
        let userAuthUID = (Auth.auth().currentUser?.uid)!
        let userShownID = uid
        
        ref.child("follows/\(userAuthUID)/following").queryOrderedByKey().observe(.value, with: { [weak self] (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    if snap.key.elementsEqual(userShownID) {
                        self?.changeBarButton(when: false)
                    }else {
                        self?.changeBarButton(when: true)
                    }
                }
            }
            
        })
    }
    
    @objc func followUser(){
        ref = Database.database().reference(fromURL: "https://kaisapp-dev.firebaseio.com")
        
        let userAuthUID = (Auth.auth().currentUser?.uid)!
        var userAuthUName:String = String()
        var following:Int = Int()
        
        let userShownID = uid
        var userShownUName:String = String()
        var followers:Int = Int()
        
        if navigationItem.rightBarButtonItem?.title?.caseInsensitiveCompare("Seguir") == ComparisonResult.orderedSame  {
            ref.child("users").child(userAuthUID).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                
                //getting auth info
                if let value = snapshot.value as? Dictionary<String, AnyObject> {
                    if value["uname"] as? String != nil {
                        userAuthUName = (value["uname"] as? String)!
                    }else {
                        userAuthUName = (Auth.auth().currentUser?.email)!
                    }
                    if value["following"] as? Int != nil {
                        following = (value["following"] as? Int)! + 1
                    }else {
                        following = 1
                    }
                }
                
                //getting shown info
                if let value = self?.users.value as? Dictionary<String, AnyObject> {
                    if value["uname"] as? String != nil {
                        userShownUName = (value["uname"] as? String)!
                    }else {
                        userShownUName = (Auth.auth().currentUser?.email)!
                    }
                    if value["followers"] as? Int != nil {
                        followers = (value["followers"] as? Int)! + 1
                    }else {
                        followers = 1
                    }
                }
                
                //setting following of auth user
                self?.ref.child("users/\(userAuthUID)/following").setValue(following)
                
                let userShown = ["\(userShownID)": userShownUName]
                
                //setting following of userauth
                self?.ref.child("follows").queryOrderedByKey().observe(.value, with: { [weak self] (snapshot) in
                    if let snap = snapshot.value as? Dictionary<String, AnyObject> {
                        if snap.keys.contains(userAuthUID) {
                            self?.ref.child("follows/\(userAuthUID)/followers").queryOrderedByKey().observe(.value, with: { [weak self] (snapshot) in
                                if let snap = snapshot.value as? Dictionary<String, AnyObject> {
                                    if snap.keys.contains(userShownID) {
                                        self?.ref.child("follows/\(userAuthUID)/following").updateChildValues(userShown)
                                    }else {
                                        self?.ref.child("follows/\(userAuthUID)/following").updateChildValues(userShown)
                                    }
                                }
                            })
                        }else {
                            self?.ref.child("follows").child(userAuthUID).child("following").setValue(userShown)
                        }
                    }
                })
                
                //setting followers user shown
                self?.ref.child("users/\(userShownID)/followers").setValue(followers)
                
                let userAuth = ["\(userAuthUID)": userAuthUName]
                
                //setting followers usershown
                self?.ref.child("follows/\(userShownID)/followers").queryOrderedByKey().observe(.value, with: { [weak self] (snapshot) in
                    if let snap = snapshot.value as? Dictionary<String, AnyObject> {
                        if snap.keys.contains(userAuthUID) {
                            self?.ref.child("follows/\(userShownID)/followers").updateChildValues(userAuth)
                        }else {
                            self?.ref.child("follows/\(userShownID)/followers").updateChildValues(userAuth)
                        }
                    }
                })
                
            })
            
            changeBarButton(when: true)
            
        }else {
            ref.child("users").child(userAuthUID).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                
                //getting auth info
                if let value = snapshot.value as? Dictionary<String, AnyObject> {
                    if value["uname"] as? String != nil {
                        userAuthUName = (value["uname"] as? String)!
                    }else {
                        userAuthUName = (Auth.auth().currentUser?.email)!
                    }
                    if value["following"] as? Int != nil {
                        following = (value["following"] as? Int)! - 1
                    }else {
                        following = 0
                    }
                }
                
                //getting shown info
                if let value = self?.users.value as? Dictionary<String, AnyObject> {
                    if value["uname"] as? String != nil {
                        userShownUName = (value["uname"] as? String)!
                    }else {
                        userShownUName = (Auth.auth().currentUser?.email)!
                    }
                    if value["followers"] as? Int != nil {
                        followers = (value["followers"] as? Int)! - 1
                    }else {
                        followers = 0
                    }
                }
                
                //setting following of auth user
                self?.ref.child("users/\(userAuthUID)/following").setValue(following)
                
                //setting followers user shown
                self?.ref.child("users/\(userShownID)/followers").setValue(followers)
            })
            
            changeBarButton(when: false)
        }
    }
    
    func changeBarButton(when following: Bool) {
        if following {
            navigationItem.rightBarButtonItem = nil
            
            let barButton = UIButton(type: .custom)
            barButton.setTitle("No Seguir", for: .normal)
            barButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            barButton.addTarget(self, action: #selector(followUser), for: .touchUpInside)
            let item = UIBarButtonItem(customView: barButton)
            
            navigationItem.setRightBarButton(item, animated: true)
        }else {
            navigationItem.rightBarButtonItem = nil
            
            let barButton = UIButton(type: .custom)
            barButton.setTitle("Seguir", for: .normal)
            barButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            barButton.addTarget(self, action: #selector(followUser), for: .touchUpInside)
            let item = UIBarButtonItem(customView: barButton)
            
            navigationItem.setRightBarButton(item, animated: true)
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
            if snapshots.count != 0 {
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
                return 1
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
            
            if userSnapshot.count > 0 {
                cell.forStaticCell(userId: uid, users: users, storageHero: storageHero, storageProfile: storageProfile)
            }else {
                cell.emptyStaticCell()
            }
            
            return cell
        }
        
        var cell:  UserProfileTableViewCell
        
        if imagesSnapshots.count != 0 {
            if indexPath.row >= imagesSnapshots.count {
                cell = tableView.dequeueReusableCell(withIdentifier: "showEmptyImagesArea", for: indexPath) as! UserProfileTableViewCell
            }else {
                cell = tableView.dequeueReusableCell(withIdentifier: "imagesArea", for: indexPath) as! UserProfileTableViewCell
                cell.imagesSnapshot = imagesSnapshots[indexPath.row]
                cell.forDynamicCells(snapshot: imagesSnapshots[indexPath.row], storage: storage)
            }
        }else {
            cell = tableView.dequeueReusableCell(withIdentifier: "showEmptyImagesArea", for: indexPath) as! UserProfileTableViewCell
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
                for user in snapshots {
                    let userID = user.key
                    if self?.uid.caseInsensitiveCompare(userID) == ComparisonResult.orderedSame {
                        self?.userSnapshot = snapshots
                        self?.users = user
                    }
                }
                self?.activityIndicatorView.stopAnimating()
                self?.showUserProfileTableView.reloadSections(IndexSet.init(integer: 0), with: UITableViewRowAnimation.none)
            }
        }
    }

}
