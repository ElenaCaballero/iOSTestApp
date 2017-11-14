//
//  UserProfileTableViewCell.swift
//  KaisApp
//
//  Created by Elena Caballero on 11/13/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import UIKit

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

    func forStaticCell() {
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
    
    func forDynamicCells() {
        heartButton.contentMode = .center
        heartButton.tintColor = UIColor.red
        heartButton.setImage(UIImage(named: "emptyLike"), for: .normal)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,YYYY"
        
    }
    
    @IBAction func heartButtonTouched(_ sender: Any) {
        if heartButton.currentImage == UIImage(named: "fullLike") {
            heartButton.setImage(UIImage(named: "emptyLike"), for: .normal)
        }else {
            heartButton.setImage(UIImage(named: "fullLike"), for: .normal)
        }
    }
}
