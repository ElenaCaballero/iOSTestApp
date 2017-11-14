//
//  ReviewViewController.swift
//  KaisApp
//
//  Created by Elena on 11/6/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import UIKit
import Cosmos

class ReviewViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var starsReview: CosmosView!
    @IBOutlet weak var titleReview: UITextField!
    @IBOutlet weak var contentReview: UITextView!
    @IBOutlet weak var sendReview: UIButton!
    
    var picker:UIImagePickerController?=UIImagePickerController()
    
    var place: Places = Places()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor(rgb: 0x2390D4)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        if starsReview.rating == 0.0 {
            sendReview.isEnabled = false
        }
        
        contentReview.delegate = self
        
        contentReview.text = "Placeholder"
        contentReview.textColor = UIColor.lightGray
        
        contentReview.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        contentReview.layer.borderWidth = 1.0
        contentReview.layer.cornerRadius = 5.0
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func galleryButtonTouched(_ sender: Any) {
        self.openGallery(picker: picker!)
    }
    
    @IBAction func cameraButtonTouched(_ sender: Any) {
        self.openCamera(picker: picker!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
