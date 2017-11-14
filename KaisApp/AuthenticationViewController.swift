//
//  AuthenticationViewController.swift
//  KaisApp
//
//  Created by Elena Caballero on 11/13/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class AuthenticationViewController: UIViewController {
    
    // MARK: - Sign Up Scene
    @IBOutlet weak var usernameSignUpTextField: UITextField!
    @IBOutlet weak var emailSignUpTextField: UITextField!
    @IBOutlet weak var passwordSignUpTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - Sign In Scene
    @IBOutlet weak var emailSignInTextField: UITextField!
    @IBOutlet weak var passwordSignInTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    // MARK: - Authenticate Scene
    @IBOutlet weak var emailAuth: UIButton!
    @IBOutlet weak var googleAuth: UIButton!
    @IBOutlet weak var facebookAuth: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpButtonTouched(_ sender: Any) {
        let email = emailSignUpTextField.text
        let password = passwordSignUpTextField.text
        let username = usernameSignUpTextField.text
        
//        if (email?.contains("@"))! {
//            if password?.count == 8 {
//                if username != nil {
//                    Auth.auth().createUser(withEmail: email!, password: password!, completion: { (user, error) in
//                        self.performSegue(withIdentifier: "signUpComplete", sender: self)
//                    })
//                }
//            }
//        }
        
        if emailSignUpTextField.text == nil {
            
        }else {
            self.performSegue(withIdentifier: "signUpComplete", sender: self)
        }
    }
    
    @IBAction func signInButtonTouched(_ sender: Any) {
        let email = emailSignInTextField.text
        let password = passwordSignInTextField.text
        
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
            
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
