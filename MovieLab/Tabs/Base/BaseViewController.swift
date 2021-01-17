//
//  BaseViewController.swift
//  MovieLab
//
//  Created by aarthur on 5/12/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    class func sizeClass() -> (vertical: UIUserInterfaceSizeClass, horizontal: UIUserInterfaceSizeClass) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let window: UIWindow = appDelegate.window!
        let vSizeClass: UIUserInterfaceSizeClass!
        let hSizeClass: UIUserInterfaceSizeClass!
        
        hSizeClass = window.traitCollection.horizontalSizeClass
        vSizeClass = window.traitCollection.verticalSizeClass
        
        return (vertical: vSizeClass, horizontal: hSizeClass)
    }
    
    func sizeClass() -> (vertical: UIUserInterfaceSizeClass, horizontal: UIUserInterfaceSizeClass) {
        return BaseViewController.sizeClass()
    }
}

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    var manuallyHandleSecondaryViewController = false
    var forwardDelegate: UISplitViewControllerDelegate? = nil
    var isOnFavorites: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.preferredDisplayMode = .allVisible
        if let nc = self.viewControllers.last as? UINavigationController {
            nc.topViewController?.navigationItem.leftBarButtonItem = self.displayModeButtonItem
            nc.topViewController?.navigationItem.leftItemsSupplementBackButton = true
        }
        
    }
    
    // MARK: - UISplitViewControllerDelegate
    
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        if splitViewController.isCollapsed {
            if self.isOnFavorites == false {
                if let tabBarController = splitViewController.viewControllers.first as? UITabBarController {
                    if let navController = tabBarController.viewControllers?.first as? UINavigationController {
                        let navVC: UINavigationController = vc as! UINavigationController
                        if let presentedVC = navVC.viewControllers.first {
                            navController.pushViewController(presentedVC, animated: true)
                            manuallyHandleSecondaryViewController = true
                            
                            // we handled the "show detail", so split view controller,
                            // please don't do anything else
                            return true
                        }
                    }
                }
            }else{
                if let tabBarController = splitViewController.viewControllers.first as? UITabBarController {
                    if let navController = tabBarController.viewControllers?.last as? UINavigationController {
                        let navVC: UINavigationController = vc as! UINavigationController
                        if let presentedVC = navVC.viewControllers.first {
                            navController.pushViewController(presentedVC, animated: true)
                            manuallyHandleSecondaryViewController = true
                            
                            // we handled the "show detail", so split view controller,
                            // please don't do anything else
                            return true
                        }
                    }
                }
            }
        }
        
        return false
    }

    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        
        guard manuallyHandleSecondaryViewController == true else {
            return nil
        }
        guard Display.isIphone() == false else {
            return nil
        }

        if splitViewController.traitCollection.horizontalSizeClass == .regular {

            if let tabBarController = splitViewController.viewControllers.first as? UITabBarController {
                var masterNavController: UINavigationController
                
                if self.isOnFavorites == false {
                    masterNavController = tabBarController.viewControllers?.first as! UINavigationController
                }else{
                    masterNavController = tabBarController.viewControllers?.last as! UINavigationController
                }
                
                var sb = self.storyboard
                var detailNavController: UINavigationController = sb?.instantiateViewController(withIdentifier: "DetailNavStackScene") as! UINavigationController

                var primaryVC: UIViewController
                
                if let presentedVC = masterNavController.popViewController(animated: false) {
                    
                    primaryVC = presentedVC
                }else{
                    sb = UIStoryboard.init(name: "Detail", bundle: nil)
                    detailNavController = sb?.instantiateInitialViewController() as! UINavigationController
                    primaryVC = detailNavController.viewControllers.first!
                }
                
                detailNavController.viewControllers = [primaryVC]
                manuallyHandleSecondaryViewController = false
                
                return detailNavController

            }
            
        }
        
        return nil
    }
    
    func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewController.DisplayMode {
        guard self.forwardDelegate != nil else {
            return .automatic
        }
        return (self.forwardDelegate?.targetDisplayModeForAction!(in: svc))!
    }
    
}
