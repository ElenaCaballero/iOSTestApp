//
//  Places.swift
//  KaisApp
//
//  Created by Elena on 11/1/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import Foundation
import UIKit

class Places {
    
    //MARK: Properties
    
    var address: String?
    var country: String?
    var images: Int?
    var img: UIImage?
    var lat: Int?
    var likes: Int?
    var lon: Int?
    var name: String
    var panos: Int?
    var reviews: Int?
    var stars: Int?
    var stars_count: Int?
    
    //MARK: Initialization
    
    init?(address: String?, country: String?, images: Int?, img: UIImage?, lat: Int?, likes: Int?,
          lon: Int?, name: String,  panos: Int?, reviews: Int?, stars: Int?, stars_count:Int?) {
        
        guard !name.isEmpty else {
            return nil
        }
        
        self.address = address
        self.country = country
        self.images = images
        self.img = img
        self.lat = lat
        self.likes = likes
        self.lon = lon
        self.name = name
        self.panos = panos
        self.reviews = reviews
        self.stars = stars
        self.stars_count = stars_count
        
    }
    
    init?(likes: Int?, reviews: Int?, images: Int?, stars_count:Int?, img: UIImage?, name: String, address: String?) {
        
        guard !name.isEmpty else {
            return nil
        }
        
        self.images = images
        self.img = img
        self.likes = likes
        self.name = name
        self.reviews = reviews
        self.stars_count = stars_count
        self.address = address
        
    }
    
    
    init?(name: String, img: UIImage?) {
        self.img = img
        self.name = name
    }
    
    init?() {
        self.name = ""
    }
    
}
