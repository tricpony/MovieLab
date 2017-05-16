//
//  AppDelegate.swift
//  MovieLab
//
//  Created by aarthur on 5/9/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootVC = sb.instantiateInitialViewController()
        
        self.window?.rootViewController = rootVC
        
        return true
    }

}
