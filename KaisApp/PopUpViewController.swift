//
//  PopUpViewController.swift
//  KaisApp
//
//  Created by Elena on 11/3/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

import Cosmos

class PopUpViewController: UIViewController, UIViewControllerTransitioningDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var picker:UIImagePickerController? = UIImagePickerController()
    
    var ref: DatabaseReference!
    var place: Places = Places()!
    var placeSnapshot: DataSnapshot = DataSnapshot()
    
    let uid = Auth.auth().currentUser?.uid
    var uname:String = String()
    var reviewId:String = String()
    
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var starsRating: CosmosView!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if galleryButton != nil {
            galleryButton.tintColor = UIColor.green
            cameraButton.tintColor = UIColor.green
            galleryButton.setTitle("Galería", for: .normal)
            galleryButton.setImage(UIImage(named: "uploadedPictures"), for: .normal)
            cameraButton.setTitle("Cámara", for: .normal)
            cameraButton.setImage(UIImage(named: "camera"), for: .normal)
        }
        
        if commentsButton != nil {
            commentsButton.setTitle("Comentario \nAdicional", for: .normal)
            sendButton.setTitle("Enviar", for: .normal)
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionClose(_:))))
    }
    
    @IBAction func sendReview(_ sender: Any) {
        ref = Database.database().reference(fromURL: "https://kaisapp-dev.firebaseio.com")
        
        let stars = Int(starsRating.rating)
        let place = self.placeSnapshot.key
        let timestamp = ServerValue.timestamp()
        
        var reviewsByUser = 1
        let reviewsByPlace = 1 + self.place.reviews!
        ref.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Dictionary<String, AnyObject> {
                if value["uname"] as? String != nil {
                    self.uname = (value["uname"] as? String)!
                }else {
                    self.uname = (Auth.auth().currentUser?.displayName)!
                }
                if value["reviews"] as? Int != nil {
                    reviewsByUser += (value["reviews"] as? Int)!
                }
            }
            
            let reviewDataValues = ["kaid": place, "stars": stars, "timestamp": timestamp, "type": "place", "uid": self.uid as Any, "uname": self.uname] as [String : AnyObject]
            
            self.ref.child("reviews_data").childByAutoId().setValue(reviewDataValues)
            
            self.ref.child("users/\(self.uid!)/reviews").setValue(reviewsByUser)
        })
        
        ref.child("reviews_data").queryLimited(toLast: 1).observe(.childAdded, with: { snapshot in
            self.reviewId = snapshot.key
            
            self.ref.child("reviews/places/\(place)").setValue([self.reviewId: timestamp])
            self.ref.child("reviews/users/\(self.uid!)/places/\(place)").setValue([self.reviewId: timestamp])
            
            let placeValues = ["reviews":reviewsByPlace, "stars": stars]
            self.ref.child("places/\(place)").setValue(placeValues)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showReview" {
            let backItem = UIBarButtonItem()
            backItem.title = place.name + ", " + place.address!
            navigationItem.backBarButtonItem = backItem
            let reviewController = segue.destination as! ReviewViewController
            reviewController.place = place
            reviewController.placeSnapshot = placeSnapshot
        }
    }
    
    @objc func actionClose(_ tap: UITapGestureRecognizer) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func galleryButtonTouched(_ sender: Any) {
        self.openGallery(picker: picker!)
    }
    
    @IBAction func cameraButtonTouched(_ sender: Any) {
        self.openCamera(picker: picker!)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject], imageView: UIImageView) {
        let chosenImage = info[(UIImagePickerControllerOriginalImage as AnyObject) as! NSObject] as! UIImage
        imageView.contentMode = .scaleAspectFit
        imageView.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    
}

extension UIViewController {
    
    func openGallery(picker: UIImagePickerController){
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func openCamera(picker: UIImagePickerController){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            present(picker, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
}
