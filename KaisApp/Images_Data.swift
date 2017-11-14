//
//  Images_Data.swift
//  KaisApp
//
//  Created by Elena Caballero on 11/6/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import Foundation
import UIKit

class Images_Data {
    
    //MARK: Properties
    
    var city: String
    var likes: Int?
    var timestamp: NSDate?
    var uname: String?
    var image: UIImage?
    
    //MARK: Initialization
    
    init?(city: String, likes: Int?, timestamp: NSDate?, uname: String?, image: UIImage?) {
        self.city = city
        self.likes = likes
        self.timestamp = timestamp
        self.uname = uname
        self.image = image
    }
    
    init?() {
        self.city = ""
    }
    
}
