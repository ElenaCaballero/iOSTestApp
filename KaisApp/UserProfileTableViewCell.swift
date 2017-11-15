//
//  UserProfileTableViewCell.swift
//  KaisApp
//
//  Created by Elena Caballero on 11/13/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseDatabase
import FirebaseStorage

class UserProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var fotosIconButton: UIButton!
    @IBOutlet weak var reviewsIconButton: UIButton!
    @IBOutlet weak var extraIconButton: UIButton!
    @IBOutlet weak var visitedIconButton: UIButton!
    @IBOutlet weak var followersIconButton: UIButton!
    @IBOutlet weak var fotosInfoLabel: UILabel!
    @IBOutlet weak var reviewsInfoLabel: UILabel!
    @IBOutlet weak var visitedInfoLabel: UILabel!
    @IBOutlet weak var followersInfoLabel: UILabel!
    @IBOutlet weak var aboutYouTextField: UITextField!
    @IBOutlet weak var aboutYouButton: UIButton!
    @IBOutlet weak var userProfileImageButton: UIButton!
    
    @IBOutlet weak var detailImages: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func emptyStaticCell() {
        heroImageView.image = UIImage(named: "hero_default")
        userProfileImageButton.frame = CGRect(x: 160, y: 100, width: 100, height: 100)
        userProfileImageButton.layer.cornerRadius = 0.5 * userProfileImageButton.bounds.size.width
        userProfileImageButton.clipsToBounds = true
        userProfileImageButton.backgroundColor = .clear
        userProfileImageButton.setImage(UIImage(named: "default_user"), for: .normal)
        fotosInfoLabel.text = "Fotos"
        reviewsInfoLabel.text = "Reseñas"
        visitedInfoLabel.text = "Visitas"
        followersInfoLabel.text = "Seguidores"
        extraIconButton.backgroundColor = UIColor(rgb: 0xFF9510)
        fotosIconButton.backgroundColor = UIColor(rgb: 0xFF9510)
        fotosIconButton.contentMode = .center
        fotosIconButton.setImage(UIImage(named: "uploadedPictures"), for: .normal)
        reviewsIconButton.backgroundColor = UIColor(rgb: 0xFF9510)
        reviewsIconButton.contentMode = .center
        reviewsIconButton.setImage(UIImage(named: "review"), for: .normal)
        visitedIconButton.backgroundColor = UIColor(rgb: 0xFF9510)
        visitedIconButton.contentMode = .center
        visitedIconButton.setImage(UIImage(named: "visited"), for: .normal)
        followersIconButton.backgroundColor = UIColor(rgb: 0xFF9510)
        followersIconButton.contentMode = .center
        followersIconButton.setImage(UIImage(named: "followers"), for: .normal)
        aboutYouButton.tintColor = UIColor.green
        aboutYouButton.contentMode = .center
        aboutYouButton.setImage(UIImage(named: "edit"), for: .normal)
    }

    func forStaticCell(userId: String, users: DataSnapshot, storageHero: StorageReference, storageProfile: StorageReference) {
        heroImageView.image = UIImage(named: "hero_default")
        userProfileImageButton.frame = CGRect(x: 160, y: 100, width: 100, height: 100)
        userProfileImageButton.layer.cornerRadius = 0.5 * userProfileImageButton.bounds.size.width
        userProfileImageButton.clipsToBounds = true
        userProfileImageButton.backgroundColor = .clear
        userProfileImageButton.setImage(UIImage(named: "default_user"), for: .normal)
        fotosInfoLabel.text = "Fotos"
        reviewsInfoLabel.text = "Reseñas"
        visitedInfoLabel.text = "Visitas"
        followersInfoLabel.text = "Seguidores"
        extraIconButton.backgroundColor = UIColor(rgb: 0xFF9510)
        fotosIconButton.backgroundColor = UIColor(rgb: 0xFF9510)
        fotosIconButton.contentMode = .center
        fotosIconButton.setImage(UIImage(named: "uploadedPictures"), for: .normal)
        reviewsIconButton.backgroundColor = UIColor(rgb: 0xFF9510)
        reviewsIconButton.contentMode = .center
        reviewsIconButton.setImage(UIImage(named: "review"), for: .normal)
        visitedIconButton.backgroundColor = UIColor(rgb: 0xFF9510)
        visitedIconButton.contentMode = .center
        visitedIconButton.setImage(UIImage(named: "visited"), for: .normal)
        followersIconButton.backgroundColor = UIColor(rgb: 0xFF9510)
        followersIconButton.contentMode = .center
        followersIconButton.setImage(UIImage(named: "followers"), for: .normal)
        aboutYouButton.tintColor = UIColor.green
        aboutYouButton.contentMode = .center
        aboutYouButton.setImage(UIImage(named: "edit"), for: .normal)
        
        var theBio: String = String()
        var theVisitors: Int = Int()
        var theFollowers: Int = Int()
        var theReviews: Int = Int()
        var theFotos: Int = Int()
        var theHero: UIImage = UIImage()
        var theProfile: UIImage = UIImage()
        
        if let aUserData = users.value as? Dictionary<String, AnyObject> {
            if aUserData["bio"] as? String != nil {
                theBio = (aUserData["bio"] as? String)!
                aboutYouTextField.text = theBio
            }
            if aUserData["images"] as? Int != nil {
                theFotos = (aUserData["images"] as? Int)!
                fotosInfoLabel.text = "\(theFotos) \nFotos"
            }
            if aUserData["reviews"] as? Int != nil {
                theReviews = (aUserData["reviews"] as? Int)!
                reviewsInfoLabel.text = "\(theReviews) \nReseñas"
            }
            if aUserData["visited"] as? Int != nil {
                theVisitors = (aUserData["visited"] as? Int)!
                visitedInfoLabel.text = "\(theVisitors) \nVisitas"
            }
            if aUserData["followers"] as? Int != nil {
                theFollowers = (aUserData["followers"] as? Int)!
                followersInfoLabel.text = "\(theFollowers) \nSeguidores"
            }
            
            
            let theURL = userId + ".jpg"
            let storageRefHero = storageHero.child(theURL)
            let storageRefProfile = storageProfile.child(theURL)
            
            storageRefHero.getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if data != nil {
                    if UIImage(data: data!) == nil{
                        theHero = UIImage(named: "hero_default")!
                        self.heroImageView.image = theHero
                    }else {
                        theHero = UIImage(data: data!)!
                        self.heroImageView.image = theHero
                    }
                }else {
                    theHero = UIImage(named: "hero_default")!
                    self.heroImageView.image = theHero
                }
            })
            
            storageRefProfile.getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if data != nil {
                    if UIImage(data: data!) == nil{
                        theProfile = UIImage(named: "default_user")!
                        self.userProfileImageButton.setImage(theProfile, for: .normal)
                    }else {
                        theProfile = UIImage(data: data!)!
                        self.userProfileImageButton.setImage(theProfile, for: .normal)
                    }
                }else {
                    theProfile = UIImage(named: "default_user")!
                    self.userProfileImageButton.setImage(theProfile, for: .normal)
                }
            })
            
        }
        
    }
    
    func forDynamicCells(snapshot: DataSnapshot, storage: StorageReference) {
        heartButton.contentMode = .center
        heartButton.tintColor = UIColor.red
        heartButton.setImage(UIImage(named: "emptyLike"), for: .normal)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,YYYY"
        
        var theImage: UIImage = UIImage()
        var theAddress: String = String()
        var theLikes: Int = Int()
        var theTime: NSDate = NSDate()
        
        if let anImageData = snapshot.value as? Dictionary<String, AnyObject> {
            let theImageURL = snapshot.key + ".jpg"
            let storageRef = storage.child(theImageURL)
            
            if anImageData["likes"] as? Int != nil {
                theLikes = (anImageData["likes"] as? Int)!
                self.likesLabel.text = ("\(String(theLikes))")
            }else{
                self.likesLabel.text = ("\(String(0))")
            }
            if anImageData["kaid"] as? String != nil {
                theAddress = (anImageData["kaid"] as? String)!
                self.addressLabel.text = "   " + theAddress
            }
            if anImageData["timestamp"] as? TimeInterval != nil {
                let t = anImageData["timestamp"] as? TimeInterval
                theTime = NSDate(timeIntervalSince1970: t!/1000)
            }else {
                theTime = NSDate()
            }
            self.dateLabel.text = "   " + String( dateFormatter.string(from: (theTime as Date)  ) )
            
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
    
    @IBAction func heartButtonTouched(_ sender: Any) {
        if heartButton.currentImage == UIImage(named: "fullLike") {
            heartButton.setImage(UIImage(named: "emptyLike"), for: .normal)
        }else {
            heartButton.setImage(UIImage(named: "fullLike"), for: .normal)
        }
    }
}
