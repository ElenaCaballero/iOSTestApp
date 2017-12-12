//
//  ViewController.swift
//  KaisApp
//
//  Created by Elena on 10/30/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import UIKit
import FirebaseDatabase
import os.log

class MainTableViewController: UITableViewController {
    
    var activityIndicatorView: UIActivityIndicatorView!
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    
    var places = Places()
    var snapshots = [DataSnapshot]()
    
    @IBOutlet weak var mainTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.color = UIColor.black
        
        mainTableView.backgroundView = activityIndicatorView
        mainTableView.rowHeight = 200.0
        
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
                self.mainTableView.separatorStyle = .none
                
                Thread.sleep(forTimeInterval: 3)
                
                OperationQueue.main.addOperation() {
                    self.mainTableView.separatorStyle = .singleLine
                    
                    self.loadContentForCells()
                }
            }
            
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return snapshots.isEmpty ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapshots.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainImageTableCell", for: indexPath) as? MainTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MainViewTableViewCell.")
        }
        
        if indexPath.row >= snapshots.count{
        } else {
            cell.placesSnapshot = snapshots[indexPath.row]
            cell.mainPlaces()
        }
        
        return cell
    }
    
    
    //MARK: - Navigation to Main Detail View
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowMainDetailView", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "ShowMainDetailView" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if indexPath.row < snapshots.count {
                    if let aPlace = snapshots[indexPath.row].value as? Dictionary<String, AnyObject> {
                        
                        let backItem = UIBarButtonItem()
                        let city = snapshots[indexPath.row].key.components(separatedBy: "-")
                        backItem.title = city[0] + ", " + (aPlace["address"] as? String)!
                        navigationItem.backBarButtonItem = backItem
                        
                        var likes:Int = Int()
                        if (aPlace["likes"] as? Int) != nil {
                            likes = (aPlace["likes"] as? Int)!
                        }else {
                            likes = 0
                        }
                        var reviews:Int = Int()
                        if (aPlace["reviews"] as? Int) != nil {
                            reviews = (aPlace["reviews"] as? Int)!
                        }else {
                            reviews = 0
                        }
                        var images:Int = Int()
                        if (aPlace["images"] as? Int) != nil {
                            images = (aPlace["images"] as? Int)!
                        }else {
                            images = 0
                        }
                        var stars_count:Int = Int()
                        if (aPlace["stars"] as? Int) != nil {
                            stars_count = (aPlace["stars"] as? Int)!
                        }else {
                            stars_count = 0
                        }
                        let name = (aPlace["name"] as? String)!
                        let address = (aPlace["address"] as? String)!
                        var img:UIImage = UIImage()
                        
                        if let anImage = aPlace["img"] as? String {
                            if let imageurl = URL(string: anImage) {
                                if let data = try? Data(contentsOf: imageurl){
                                    img = UIImage(data: data)!
                                }else {
                                    img = UIImage(named: "error_image")!
                                }
                            }else {
                                img = UIImage(named: "error_image")!
                            }
                        }else{
                            img = UIImage(named: "error_image")!
                        }
                        
                        let destinationViewController = segue.destination as! MainDetailTableViewController
                        
                        guard let place = Places(likes: likes, reviews: reviews, images: images, stars_count: stars_count, img: img, name: name, address: address)
                            else {
                                    fatalError("Unable to instantiate image data")
                                }
                        destinationViewController.kaid = snapshots[indexPath.row].key
                        destinationViewController.place = place
                        destinationViewController.placeSnapshot = snapshots[indexPath.row]
                    }
                }
            }
        }
    }
    
    //MARK: - Tabs Initializer
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Initialize Tab Bar Item
        tabBarItem = UITabBarItem(title: "Destinos", image: UIImage(named: "location"), tag: 1)
    }
    
    //MARK: - Database Connection
    
    var ref: DatabaseReference!
    
    func loadContentForCells(){
        ref = Database.database().reference(fromURL: "https://kaisapp-dev.firebaseio.com").child("places")
        
        ref.queryOrdered(byChild: "images").observe(.value) { [weak self] (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                self?.snapshots = snapshots.reversed()
                self?.activityIndicatorView.stopAnimating()
                self?.mainTableView.reloadData()
            }
        }
    }

}

//MARK: - UIColor Extension

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
