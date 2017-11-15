//
//  MainDetailHeader.swift
//  KaisApp
//
//  Created by Elena Caballero on 11/9/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import UIKit

class MainDetailHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var imagesReviewsSegmentedControl: UISegmentedControl!
    
    func setupSegmentedControl(){
        imagesReviewsSegmentedControl.tintColor = UIColor(rgb: 0xFF9510)
        imagesReviewsSegmentedControl.setTitle("Fotos", forSegmentAt: 0)
        imagesReviewsSegmentedControl.setTitle("Reseñas", forSegmentAt: 1)
    }
    
    func setupSegmentedControlUserProfile(){
        imagesReviewsSegmentedControl.tintColor = UIColor(rgb: 0xFF9510)
        imagesReviewsSegmentedControl.setTitle("Fotos", forSegmentAt: 0)
        imagesReviewsSegmentedControl.setTitle("Reseñas", forSegmentAt: 1)
        imagesReviewsSegmentedControl.insertSegment(withTitle: "Seguidores", at: 2, animated: true)
    }

}
