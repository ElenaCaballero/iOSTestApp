//
//  MainDetailTableViewController.swift
//  KaisApp
//
//  Created by Elena Caballero on 11/9/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class MainDetailTableViewController: UITableViewController {
    
    var activityIndicatorView: UIActivityIndicatorView!
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    
    var place: Places = Places()!
    var snapshots = [DataSnapshot]()
    var placeSnapshot:DataSnapshot = DataSnapshot()
    var countSnapshots = 0
    
    var buttonIndexPath: IndexPath = IndexPath()
    
    let transition = PopAnimator()

    @IBOutlet var mainDetailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.color = UIColor.black
        
        if mainDetailTableView != nil {
            mainDetailTableView.backgroundView = activityIndicatorView
            
            mainDetailTableView.register(UINib.init(nibName: "MainDetailHeader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "MainDetailHeaderID")
        }
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
                self.mainDetailTableView.separatorStyle = .none
                
                Thread.sleep(forTimeInterval: 3)
                
                OperationQueue.main.addOperation() {
                    self.mainDetailTableView.separatorStyle = .singleLine
                    
                    self.loadImageContentForCells()
                }
            }
            
        }
    }
    
    //MARK: - Stars and Fotos PopUps
    
    @IBAction func starsButtonTouched(_ sender: Any) {
        let starsPopOver = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "starsPopUp") as? PopUpViewController
        starsPopOver?.placeSnapshot = placeSnapshot
        starsPopOver?.place = place
        starsPopOver?.transitioningDelegate = self as? UIViewControllerTransitioningDelegate
        starsPopOver?.modalPresentationStyle = .overFullScreen
        starsPopOver?.modalTransitionStyle = .crossDissolve
        present(starsPopOver!, animated: true, completion: nil)
    }
    
    @IBAction func fotosButtonTouched(_ sender: Any) {
        let fotosPopOver = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "fotosPopUp")
        fotosPopOver.transitioningDelegate = self as? UIViewControllerTransitioningDelegate
        fotosPopOver.modalPresentationStyle = .overFullScreen
        fotosPopOver.modalTransitionStyle = .crossDissolve
        present(fotosPopOver, animated: true, completion: nil)
    }
    
    //MARK: - Navigation to Images Detail View and Reviews View and Users Profile View
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showImagesDetailViewMain", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showReview" {
            let backItem = UIBarButtonItem()
            backItem.title = place.name.capitalizingFirstLetter() + ", " + place.address!
            navigationItem.backBarButtonItem = backItem
            let reviewController = segue.destination as! ReviewViewController
            reviewController.place = place
            reviewController.placeSnapshot = placeSnapshot
        }
        
        if segue.identifier == "showImagesDetailViewMain" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationViewController = segue.destination as! ImagesDetailViewController
                destinationViewController.snap = snapshots[indexPath.row]
                destinationViewController.storage = Storage.storage().reference(forURL: "gs://kaisapp-dev.appspot.com/images")
            }
        }
        
        if segue.identifier == "showUserView" {
            let destinationViewController = segue.destination as! ShowUserProfileTableViewController
            if let button = sender as? UIButton {
                let buttonPosition:CGPoint = button.convert(CGPoint.zero, to:self.tableView)
                buttonIndexPath = self.tableView.indexPathForRow(at: buttonPosition)!
            }
            let thing = snapshots[buttonIndexPath.row].value as? Dictionary<String, AnyObject>
            let backItem = UIBarButtonItem()
            backItem.title = ((thing!["uname"] as! String))
            navigationItem.backBarButtonItem = backItem
            let uid = (thing!["uid"]  as! String)
            destinationViewController.uid = uid
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (indexPath.section == 1) {
            return indexPath;
        }
        return nil;
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.section == 1)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            let placeName = place.name.removingWhitespaces()
            if snapshots.count > 0 {
                for snap in snapshots {
                    let thing = snap.value as? Dictionary<String, AnyObject>
                    let token = (thing!["kaid"] as! String).components(separatedBy: "-")
                    if placeName.caseInsensitiveCompare(token[0]) == ComparisonResult.orderedSame {
                        countSnapshots += 1
                    }
                }
                return countSnapshots
            }else {
                return 0
            }
        default:
            assert(false, "section \(section)")
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainArea", for: indexPath) as! MainDetailTableViewCell
            
            cell.placesSnapshot = placeSnapshot
            cell.forStaticCell(place: place)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "imagesArea", for: indexPath) as! MainDetailTableViewCell
        
        if indexPath.row >= snapshots.count{
            cell.backgroundColor = UIColor.black
        } else {
            cell.imagesSnapshot = snapshots[indexPath.row]
            cell.forDynamicCells(snapshot: snapshots[indexPath.row], storage: storage)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 400
        }
        return 200
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.mainDetailTableView.dequeueReusableHeaderFooterView(withIdentifier: "MainDetailHeaderID")
        if let mainDetailHeader = header as? MainDetailHeader{
            mainDetailHeader.setupSegmentedControl()
        }
        return header
    }
    
    // MARK: - Database connection
    
    var ref: DatabaseReference!
    var storage: StorageReference!
    
    func loadImageContentForCells(){
        ref = Database.database().reference(fromURL: "https://kaisapp-dev.firebaseio.com").child("images_data")
        storage = Storage.storage().reference(forURL: "gs://kaisapp-dev.appspot.com/images")
        
        ref.queryOrdered(byChild: "timestamp").observe(.value) { [weak self] (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                self?.snapshots = snapshots
                self?.activityIndicatorView.stopAnimating()
                self?.mainDetailTableView.reloadSections(IndexSet.init(integer: 1), with: UITableViewRowAnimation.none)
            }
        }
    }

}

// MARK: - Transitions Extension

extension MainDetailTableViewController: UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
    }
}

// MARK: - Remove Whitespace Extension

extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
