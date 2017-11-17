//
//  TableViewHelper.swift
//  KaisApp
//
//  Created by Elena Caballero on 11/13/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import Foundation
import UIKit

class TableViewHelper {
    
    class func EmptyMessage(message: String, viewController: UITableViewController) {
        let messageLabel = UILabel(frame: CGRect(x: 0,y: 0,width: viewController.view.bounds.size.width, height: viewController.view.bounds.size.height*2))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "System", size: 20)
        messageLabel.sizeToFit()
        
        viewController.tableView.backgroundView = messageLabel;
        viewController.tableView.separatorStyle = .none;
    }
    
    class func EmptyCell(message: String, cell: UITableViewCell) {
        let messageLabel = UILabel(frame: CGRect(x: 0,y: 0,width: cell.bounds.size.width, height: cell.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "System", size: 20)
        messageLabel.sizeToFit()
        
        cell.backgroundView = messageLabel
    }
}
