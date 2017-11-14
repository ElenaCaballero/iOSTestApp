//
//  PopUpViewController.swift
//  KaisApp
//
//  Created by Elena on 11/3/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController, UIViewControllerTransitioningDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var picker:UIImagePickerController? = UIImagePickerController()
    
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if galleryButton != nil {
            galleryButton.tintColor = UIColor.green
            cameraButton.tintColor = UIColor.green
            galleryButton.setTitle("Galería", for: .normal)
            galleryButton.setImage(UIImage(named: "uploadedPictures"), for: .normal)
            cameraButton.setTitle("Cámara", for: .normal)
            cameraButton.setImage(UIImage(named: "camera"), for: .normal)
        }
        
        if commentsButton != nil {
            commentsButton.setTitle("Comentario \nAdicional", for: .normal)
            sendButton.setTitle("Enviar", for: .normal)
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionClose(_:))))
    }
    
    @objc func actionClose(_ tap: UITapGestureRecognizer) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func galleryButtonTouched(_ sender: Any) {
        self.openGallery(picker: picker!)
    }
    
    @IBAction func cameraButtonTouched(_ sender: Any) {
        self.openCamera(picker: picker!)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject], imageView: UIImageView) {
        let chosenImage = info[(UIImagePickerControllerOriginalImage as AnyObject) as! NSObject] as! UIImage
        imageView.contentMode = .scaleAspectFit
        imageView.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension UIViewController {
    
    func openGallery(picker: UIImagePickerController){
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func openCamera(picker: UIImagePickerController){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            present(picker, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
}