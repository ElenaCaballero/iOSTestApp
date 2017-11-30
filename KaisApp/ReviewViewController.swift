//
//  ReviewViewController.swift
//  KaisApp
//
//  Created by Elena on 11/6/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

import Cosmos

class ReviewViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var starsReview: CosmosView!
    @IBOutlet weak var titleReview: UITextField!
    @IBOutlet weak var contentReview: UITextView!
    @IBOutlet weak var sendReview: UIButton!
    
    var picker:UIImagePickerController?=UIImagePickerController()
    
    var ref: DatabaseReference!
    var place: Places = Places()!
    var placeSnapshot: DataSnapshot = DataSnapshot()
    
    let uid = Auth.auth().currentUser?.uid
    var uname:String = String()
    var reviewId:String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor(rgb: 0x2390D4)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        contentReview.delegate = self
        
        contentReview.text = "Mensaje..."
        contentReview.textColor = UIColor.lightGray
        
        contentReview.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        contentReview.layer.borderWidth = 1.0
        contentReview.layer.cornerRadius = 5.0
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func galleryButtonTouched(_ sender: Any) {
        self.openGallery(picker: picker!)
    }
    
    @IBAction func cameraButtonTouched(_ sender: Any) {
        self.openCamera(picker: picker!)
    }
    
    @IBAction func sendReview(_ sender: Any) {
        ref = Database.database().reference(fromURL: "https://kaisapp-dev.firebaseio.com")
        
        var title:String = String()
        if titleReview.text == "" {
            title = ""
        }else {
            title = titleReview.text!
        }
        var message:String = String()
        if contentReview.text == "Mensaje..." {
            message = ""
        }else {
            message = contentReview.text!
        }
        let stars = Int(starsReview.rating)
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
            
            let reviewDataValues = ["kaid": place, "message": message as Any, "stars": stars, "timestamp": timestamp, "title": title as Any, "type": "place", "uid": self.uid as Any, "uname": self.uname] as [String : AnyObject]
            self.ref.child("reviews_data").childByAutoId().setValue(reviewDataValues)
            
            self.ref.child("users/\(self.uid!)/reviews").setValue(reviewsByUser)
        })
        
        ref.child("reviews_data").queryLimited(toLast: 1).observe(.childAdded, with: { snapshot in
            self.reviewId = snapshot.key
            
            self.ref.child("reviews/places/\(place)/\(self.reviewId)").setValue(timestamp)
            self.ref.child("reviews/users/\(self.uid!)/places/\(place)/\(self.reviewId)").setValue(timestamp)

            self.ref.child("places/\(place)/reviews").setValue(reviewsByPlace)
            self.ref.child("places/\(place)/stars").setValue(stars)
        })
        
        titleReview.text = ""
        contentReview.text = "Mensaje..."
        starsReview.rating = 0.0
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
        }
    }

}
