//
//  AuthenticationViewController.swift
//  KaisApp
//
//  Created by Elena Caballero on 11/13/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseAuthUI
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit

class AuthenticationViewController: UIViewController, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {
    
    
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
    @IBOutlet weak var googleAuth: GIDSignInButton!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    var ref: DatabaseReference!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfUserIsSignedIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "bg_login")
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        
        self.hideKeyboardWhenTappedAround()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        if googleAuth != nil {
            googleAuth.style = .wide
        }

        if let button = self.fbLoginButton {
            button.delegate = self
        }
        
    }
    
    func checkIfUserIsSignedIn() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                self.present(vc!, animated: true, completion: nil)
            }
        }
    }
    
    //MARK:- Sign in with Google prompts
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Email/Password Sign In/Up methods
    
    @IBAction func signUpAction(_ sender: Any) {
        if emailSignUpTextField.text == "" {
            let alert = UIAlertController(title: "Alerta", message: "Debe ingresar un correo electrónico", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            if usernameSignUpTextField.text == "" {
                let alert = UIAlertController(title: "Alerta", message: "Debe ingresar un nombre de usuario", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }else {
                Auth.auth().createUser(withEmail: emailSignUpTextField.text!, password: passwordSignUpTextField.text!) { (user, error) in
                    if error == nil {
                        print("Se ha creado un usuario correctamente")
                        self.ref = Database.database().reference(fromURL: "https://kaisapp-dev.firebaseio.com")
                        let values = ["followers": 0, "following": 0, "images": 0, "reviews": 0, "uname": self.usernameSignUpTextField.text as Any, "visited": 0 ] as [String : AnyObject]
                        self.ref.child("users").child((user?.uid)!).setValue(values)
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                        self.present(vc!, animated: true, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            
        }
    }
    
    @IBAction func signInAction(_ sender: Any) {
        if emailSignInTextField.text == "" || passwordSignInTextField.text == "" {
            let alert = UIAlertController(title: "Alerta", message: "Debe ingresar su correo electrónico y/o contraseña", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
        }else {
            Auth.auth().signIn(withEmail: emailSignInTextField.text!, password: passwordSignInTextField.text!, completion: { (user, error) in
                if error == nil {
                    print("Se ha autenticado correctamente")
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    self.present(vc!, animated: true, completion: nil)
                }else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
    }
    
    //MARK:- FBSDKLoginButtonDelegate methods
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if(error == nil){
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    let alertController = UIAlertController(title: "Error de Autenticación", message: error.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                self.ref = Database.database().reference(fromURL: "https://kaisapp-dev.firebaseio.com").child("users").child((user?.uid)!)
                let values = ["followers": 0, "following": 0, "images": 0, "reviews": 0, "uname": user?.displayName as Any, "visited": 0 ] as [String : AnyObject]
                self.ref.updateChildValues(values, withCompletionBlock: { (error, reference) in
                    if error != nil {
                        print(error!)
                        return
                    }
                })
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                self.present(vc!, animated: true, completion: nil)
            }
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged out of facebook")
    }
    
}
