//
//  MainDetailTableViewCell.swift
//  KaisApp
//
//  Created by Elena Caballero on 11/9/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class MainDetailTableViewCell: UITableViewCell {
    
    var storage: StorageReference!
    var ref: DatabaseReference!
    
    var placesSnapshot: DataSnapshot!
    var imagesSnapshot: DataSnapshot!
    
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var fotosButton: UIButton!
    @IBOutlet weak var reviewsButton: UIButton!
    @IBOutlet weak var starsButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var fotosLabel: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var barInfoLabels: UIStackView!
    @IBOutlet weak var barIconButtons: UIStackView!
    @IBOutlet weak var detailImages: UIImageView!
    @IBOutlet weak var detailUsername: UIButton!
    @IBOutlet weak var detailDate: UILabel!
    @IBOutlet weak var detailLikesButton: UIButton!
    @IBOutlet weak var detailLikesLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if detailLikesLabel != nil, detailImage != nil, likeLabel != nil, fotosLabel != nil, reviewsLabel != nil, starsLabel != nil, detailDate != nil, detailImages != nil {
            detailImage.image = nil
            likeLabel.text = ""
            fotosLabel.text = ""
            reviewsLabel.text = ""
            starsLabel.text = ""
            detailLikesLabel.text = ""
            detailDate.text = ""
            detailImages.image = nil
        }
    }
    
    var checked = false
    
    @IBAction func likeButtonTouched(_ sender: UIButton) {
        ref = Database.database().reference(fromURL: "https://kaisapp-dev.firebaseio.com")
        if checked {
            let likesString = likeLabel.text?.components(separatedBy: "\n")
            let newAmountLikes = Int(likesString![0])! - 1
            let placeUID = placesSnapshot.key
            ref.child("places/\(placeUID)/likes").setValue(newAmountLikes)
            likeLabel.text = ("\(String(newAmountLikes))\nme gusta")
            sender.setImage(UIImage(named: "emptyLike"), for: .normal)
            checked = false
        }else {
            let likesString = likeLabel.text?.components(separatedBy: "\n")
            let newAmountLikes = Int(likesString![0])! + 1
            let placeUID = placesSnapshot.key
            ref.child("places/\(placeUID)/likes").setValue(newAmountLikes)
            likeLabel.text = ("\(String(newAmountLikes))\nme gusta")
            sender.setImage(UIImage(named: "fullLike"), for: .normal)
            checked = true
        }
    }
    
    var checkedDetail = false
    
    @IBAction func detailLikeButtonTouched(_ sender: UIButton) {
        ref = Database.database().reference(fromURL: "https://kaisapp-dev.firebaseio.com")
        if checkedDetail {
            let newAmountLikes = Int(detailLikesLabel.text!)! - 1
            let imageUID = imagesSnapshot.key
            ref.child("images_data/\(imageUID)/likes").setValue(newAmountLikes)
            detailLikesLabel.text = ("\(String(newAmountLikes))")
            sender.setImage(UIImage(named: "emptyLike"), for: .normal)
            checkedDetail = false
        }else {
            let newAmountLikes = Int(detailLikesLabel.text!)! + 1
            let imageUID = imagesSnapshot.key
            ref.child("images_data/\(imageUID)/likes").setValue(newAmountLikes)
            detailLikesLabel.text = ("\(String(newAmountLikes))")
            sender.setImage(UIImage(named: "fullLike"), for: .normal)
            checkedDetail = true
        }
    }
    
    
    func forStaticCell(place: Places){
        barInfoLabels.backgroundColor = UIColor.orange
        likeButton.contentMode = .center
        likeButton.tintColor = UIColor.red
        likeLabel.backgroundColor = UIColor(rgb: 0xFF9510)
        fotosButton.tintColor = UIColor.green
        fotosButton.contentMode = .center
        fotosLabel.backgroundColor = UIColor(rgb: 0xFF9510)
        reviewsButton.tintColor = UIColor.green
        reviewsButton.contentMode = .center
        reviewsLabel.backgroundColor = UIColor(rgb: 0xFF9510)
        starsButton.contentMode = .center
        starsButton.tintColor = UIColor(rgb: 0xffc046)
        starsLabel.backgroundColor = UIColor(rgb: 0xFF9510)
        
        
        if let placeImage = place.img {
            detailImage.image = placeImage
            
            if !checked {
                likeButton.setImage(UIImage(named: "emptyLike"), for: .normal)
            }else {
                likeButton.setImage(UIImage(named: "fullLike"), for: .normal)
            }
            fotosButton.setImage(UIImage(named: "camera"), for: .normal)
            reviewsButton.setImage(UIImage(named: "review"), for: .normal)
            starsButton.setImage(UIImage(named: "filledStar"), for: .normal)
            
            likeLabel.text = ("\(String(place.likes!))\nme gusta")
            fotosLabel.text = ("\(String(place.images!))\nfotos")
            reviewsLabel.text = ("\(String(place.reviews!))\nreseñas")
            starsLabel.text = ("\(String(place.stars_count!))\nestrellas")
        }
    }
    
    func forDynamicCells(snapshot: DataSnapshot, storage: StorageReference){
        detailUsername.contentHorizontalAlignment = .left
        
        detailLikesButton.contentMode = .center
        detailLikesButton.tintColor = UIColor.red
        if !checkedDetail {
            detailLikesButton.setImage(UIImage(named: "emptyLike"), for: .normal)
        }else {
            detailLikesButton.setImage(UIImage(named: "fullLike"), for: .normal)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,YYYY"
        
        var theImage: UIImage = UIImage()
        var theUName: String = String()
        var theLikes: Int = Int()
        var theTime: NSDate = NSDate()
        
        if let anImageData = snapshot.value as? Dictionary<String, AnyObject> {
            let theImageURL = snapshot.key + ".jpg"
            let storageRef = storage.child(theImageURL)
            
            if anImageData["likes"] as? Int != nil {
                theLikes = (anImageData["likes"] as? Int)!
                self.detailLikesLabel.text = ("\(String(theLikes))")
            }else{
                self.detailLikesLabel.text = ("\(String(0))")
            }
            if anImageData["uname"] as? String != nil {
                theUName = (anImageData["uname"] as? String)!
                self.detailUsername.setTitle("   " + theUName, for: .normal)
            }
            if anImageData["timestamp"] as? TimeInterval != nil {
                let t = anImageData["timestamp"] as? TimeInterval
                theTime = NSDate(timeIntervalSince1970: t!/1000)
            }else {
                theTime = NSDate()
            }
            self.detailDate.text = "   " + String( dateFormatter.string(from: (theTime as Date)  ) )
            
            storageRef.getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if data != nil {
                    if UIImage(data: data!) == nil{
                        theImage = UIImage(named: "error_image")!
                        self.detailImages.image = theImage
                    }else {
                        theImage = UIImage(data: data!)!
                        self.detailImages.image = theImage
                    }
                }else {
                    theImage = UIImage(named: "error_image")!
                    self.detailImages.image = theImage
                }
            })
        }
    }
}


