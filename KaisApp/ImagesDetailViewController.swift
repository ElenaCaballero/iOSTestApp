//
//  ImagesDetailViewController.swift
//  KaisApp
//
//  Created by Elena on 11/2/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class ImagesDetailViewController: UIViewController, UIScrollViewDelegate {

    var snap: DataSnapshot!
    var storage: StorageReference!
    
    var activityIndicatorView: UIActivityIndicatorView!
    var monitor = 0
    
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var zoomGesture: UIPinchGestureRecognizer!
    @IBOutlet var imagesDetailView: UIView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var hearts: UIButton!
    @IBOutlet weak var imageDetail: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var Address: UILabel!
    
    func prepareForReuse() {
        if likesLabel != nil, Address != nil {
            likesLabel.text = ""
            Address.text = ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        activityIndicatorView.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        activityIndicatorView.center = CGPoint(x: imagesDetailView.frame.size.width / 2,
                                               y: imagesDetailView.frame.size.height / 2);
        imagesDetailView.addSubview(activityIndicatorView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        hearts.contentMode = .center
        hearts.tintColor = UIColor.red
        hearts.setImage(UIImage(named: "fullLike"), for: .normal)
        
        if monitor == 0 {
            activityIndicatorView.startAnimating()
            
            dispatchQueue.async {
                
                Thread.sleep(forTimeInterval: 5)
                
                OperationQueue.main.addOperation() {
                    self.setData()
                }
            }
            
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageDetail
    }
    
    @IBAction func closeButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
    }
    
    func setData() {
        if let aData = snap.value as? Dictionary<String, AnyObject> {
            if (aData["kaid"] as? String) != nil {
                if (aData["uname"] as? String) != nil {
                    Address.text = (aData["uname"] as? String)! + ", " + (aData["kaid"] as? String)!
                }
            }
            if (aData["likes"] as? Int) != nil {
                likesLabel.text = String((aData["likes"] as? Int)!)
            }else{
                likesLabel.text = String(0)
            }
            
            let theImageURL = snap.key + ".jpg"
            let storageRef = storage.child(theImageURL)
            
            storageRef.getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if data != nil {
                    if UIImage(data: data!) == nil{
                        self.imageDetail.image = UIImage(named: "error_image")!
                    }else {
                        self.imageDetail.image = UIImage(data: data!)!
                    }
                }else {
                    self.imageDetail.image = UIImage(named: "error_image")!
                }
                
                self.monitor = 1
                
                self.activityIndicatorView.stopAnimating()
            })
        }
    }
    

}
