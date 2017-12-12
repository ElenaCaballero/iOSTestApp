//
//  UserProfileTableViewController.swift
//  KaisApp
//
//  Created by Elena Caballero on 11/13/17.
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

class UserProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImagePickerDelegate {
    
    var rightBarButtonItem: UIBarButtonItem!
    
    var activityIndicatorView: UIActivityIndicatorView!
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    
    var picker:UIImagePickerController? = UIImagePickerController()
    
    var uid:String = String()
    var snapshots = [DataSnapshot]()
    var imagesSnapshots = [DataSnapshot]()
    var userSnapshot = [DataSnapshot]()
    var users = DataSnapshot()

    @IBOutlet var userProfileTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker?.delegate = self
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.color = UIColor.black
        
        self.hideKeyboardWhenTappedAround()
        
        if userProfileTableView != nil {
            userProfileTableView.addSubview(activityIndicatorView)
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorView.hidesWhenStopped = true
            activityIndicatorView.color = UIColor.black
            let horizontalConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            userProfileTableView.addConstraint(horizontalConstraint)
            let verticalConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
            userProfileTableView.addConstraint(verticalConstraint)
            
            userProfileTableView.register(UINib.init(nibName: "MainDetailHeader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "MainDetailHeaderID")
        }
        
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
                self.userProfileTableView.separatorStyle = .none
                
                Thread.sleep(forTimeInterval: 3)
                
                OperationQueue.main.addOperation() {
                    self.userProfileTableView.separatorStyle = .singleLine
                    
                    self.loadImageContentForCells()
                    self.loadUserContent()
                    
                    if Auth.auth().currentUser != nil {
                        self.uid = (Auth.auth().currentUser?.uid)!
                        self.ref = Database.database().reference(fromURL: "https://kaisapp-dev.firebaseio.com").child("users")
                        self.ref.child(self.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                            self.users = snapshot
                            if let value = snapshot.value as? Dictionary<String, AnyObject> {
                                if value["uname"] as? String != nil {
                                    self.navigationItem.title = (value["uname"] as? String)!
                                }else {
                                    self.navigationItem.title = (Auth.auth().currentUser?.email)!
                                }
                            }
                        })
                    }
                }
            }
            
        }
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
    
    
    @IBAction func logOutAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Desconectar", message: "Está seguro que desea cerrar sesión?", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            if (FBSDKAccessToken.current()) != nil {
                FBSDKLoginManager().logOut()
                try! Auth.auth().signOut()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Authenticate")
                self.present(vc!, animated: true, completion: nil)
            }else if GIDSignIn.sharedInstance().currentUser != nil {
                GIDSignIn.sharedInstance().signOut()
                try! Auth.auth().signOut()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Authenticate")
                self.present(vc!, animated: true, completion: nil)
            }else{
                do {
                    try Auth.auth().signOut()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Authenticate")
                    self.present(vc!, animated: true, completion: nil)
                    
                } catch let error as NSError {
                    print("Logging ouuuut\(error.localizedDescription)")
                }
            }
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel button tapped")
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion:nil)
        
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
        let header = self.userProfileTableView.dequeueReusableHeaderFooterView(withIdentifier: "MainDetailHeaderID")
        if let mainDetailHeader = header as? MainDetailHeader{
            mainDetailHeader.setupSegmentedControlUserProfile()
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
            
            cell.delegate = self
            if userSnapshot.count > 0 {
                cell.forStaticCell(userId: uid, users: users, storageHero: storageHero, storageProfile: storageProfile)
            }else {
                cell.emptyStaticCell()
            }
            
            return cell
        }
        
        var cell:UserProfileTableViewCell
        
        if imagesSnapshots.count != 0 {
            if indexPath.row >= imagesSnapshots.count {
                cell = tableView.dequeueReusableCell(withIdentifier: "emptyImagesArea", for: indexPath) as! UserProfileTableViewCell
            }else {
                cell = tableView.dequeueReusableCell(withIdentifier: "imagesArea", for: indexPath) as! UserProfileTableViewCell
                cell.imagesSnapshot = imagesSnapshots[indexPath.row]
                cell.forDynamicCells(snapshot: imagesSnapshots[indexPath.row], storage: storage)
            }
        }else {
            cell = tableView.dequeueReusableCell(withIdentifier: "emptyImagesArea", for: indexPath) as! UserProfileTableViewCell
        }
        
        return cell
    }
    
    func pickImage() {
        picker?.delegate = self
        picker?.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker?.allowsEditing = false
        self.present(picker!, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let cell = tableView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath) as! UserProfileTableViewCell
        
        cell.heroImageView.image = image
        
        cell.userProfileImageButton.contentMode = .scaleAspectFit
        cell.userProfileImageButton.setImage(image, for: .normal)
        
        picker.dismiss(animated: true, completion: nil)
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
                for snap in snapshots {
                     if let snaps = snap.value as? Dictionary<String, AnyObject> {
                        if (snaps["uid"] as? String) != nil {
                            let uids = snaps["uid"] as! String
                            let currentuid = self?.uid
                            if uids.caseInsensitiveCompare(currentuid!) == ComparisonResult.orderedSame {
                                print("Snapshots: \(snapshots)")
                                self?.snapshots = snapshots
                                self?.activityIndicatorView.stopAnimating()
                                self?.userProfileTableView.reloadSections(IndexSet.init(integer: 1), with: UITableViewRowAnimation.none)
                            }else {
                                self?.activityIndicatorView.stopAnimating()
                                self?.userProfileTableView.reloadSections(IndexSet.init(integer: 1), with: UITableViewRowAnimation.none)
                            }
                        }else {
                            self?.activityIndicatorView.stopAnimating()
                            self?.userProfileTableView.reloadSections(IndexSet.init(integer: 1), with: UITableViewRowAnimation.none)
                        }
                    }
                }
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
                self?.userProfileTableView.reloadSections(IndexSet.init(integer: 0), with: UITableViewRowAnimation.none)
            }
        }
    }
    
    //MARK: - Tabs Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tabBarItem = UITabBarItem(title: "Perfil", image: UIImage(named: "user"), tag: 1)
    }

}

//MARK: - For dismissing keyboard

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UITableView {
    func indexPath(for view: UIView) -> IndexPath? {
        let location = view.convert(CGPoint.zero, to: self)
        return self.indexPathForRow(at: location)
    }
}

protocol ImagePickerDelegate {
    
    func pickImage()
}
