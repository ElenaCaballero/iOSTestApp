//
//  AppDelegate.swift
//  KaisApp
//
//  Created by Elena on 10/30/17.
//  Copyright © 2017 Elena Caballero. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseAuthUI
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate{
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.statusBarStyle = .lightContent
        FirebaseApp.configure()
        
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self as? FUIAuthDelegate
        
        GIDSignIn.sharedInstance().clientID = "222943743007-haq6i7t6inv3rb4flsfvtiljo4umn0jr.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        if window?.rootViewController as? UITabBarController != nil {
            let tabBarController = window!.rootViewController as! UITabBarController
            tabBarController.selectedIndex = 2
        }
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            if(GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])){
                return true
            }else if(FBSDKApplicationDelegate.sharedInstance().application(application, open: url, options: options)){
                return true
            }
            return false
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print("Sign in error: \(error.localizedDescription)")
            return
        }else{
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    print("Error al autenticarse: \(error.localizedDescription)")
                    return
                }else{
                    print("Se ha autenticado correctamente yay")
                    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "Home")
                    
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    self.window?.rootViewController = vc
                    self.window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Se ha desconectado de la aplicación: \(error.localizedDescription)")
    }
    
    /*func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Hubo un error al hacer sign in: \(error.localizedDescription)")
        }
        else {
            let authentication = user.authentication
            let credentials = GoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!)
            Auth.auth().signIn(with: credentials, completion: { (user, error) in
                if let error = error {
                    print("Error al autenticarse: \(error.localizedDescription)")
                    return
                }else{
                    print("Se ha autenticado correctamente")
                }
            })
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Se ha desconectado de la aplicación: \(error.localizedDescription)")
    }*/
    
}

