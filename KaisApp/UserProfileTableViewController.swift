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

class UserProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        
        userProfileTableView.backgroundView = activityIndicatorView
        
        self.hideKeyboardWhenTappedAround()
        
        if Auth.auth().currentUser != nil {
            uid = (Auth.auth().currentUser?.uid)!
            ref = Database.database().reference(fromURL: "https://kaisapp-dev.firebaseio.com").child("users")
            ref.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
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
        
        userProfileTableView.register(UINib.init(nibName: "MainDetailHeader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "MainDetailHeaderID")
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
        print("Logging oout")
        let alertController = UIAlertController(title: "Desconectar", message: "Está seguro que desea cerrar sesión?", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Ok button tapped")
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
            print("Cancel button tapped");
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
            
            if userSnapshot.count > 0 {
                print("UserSnapshots greater than 0")
                cell.forStaticCell(userId: uid, users: users, storageHero: storageHero, storageProfile: storageProfile)
            }else {
                print("UserSnapshots less than 0")
                cell.emptyStaticCell()
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "imagesArea", for: indexPath) as! UserProfileTableViewCell
        
        if imagesSnapshots.count > 0 {
            print("ImagesSnapshots: %d", imagesSnapshots.count)
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
            print("ImagesSnapshots: %d", imagesSnapshots.count)
            cell.emptyDynamicCell()
        }
        
        return cell
    }
    
    //MARK: - For opening gallery

    @IBAction func userProfileButtonTouched(_ sender: Any) {
        picker!.allowsEditing = false
        picker!.sourceType = .photoLibrary
        
        present(picker!, animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            let indexPath = tableView.indexPath(for: self.tableView)
            let cell = tableView.dequeueReusableCell(withIdentifier: "userInfo", for: indexPath!) as! UserProfileTableViewCell
            cell.userProfileImageButton.contentMode = .scaleAspectFit
            cell.userProfileImageButton.setImage(pickedImage, for: .normal)
        }
        dismiss(animated: true, completion: nil)
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
                self?.userProfileTableView.reloadSections(IndexSet.init(integer: 1), with: UITableViewRowAnimation.none)
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
