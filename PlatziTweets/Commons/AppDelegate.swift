//
//  AppDelegate.swift
//  PlatziTweets
//
//  Created by Pedro Rodríguez on 29/06/21.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        return true
    }


}

