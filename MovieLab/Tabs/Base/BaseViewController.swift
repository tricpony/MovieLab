//
//  BaseViewController.swift
//  MovieLab
//
//  Created by aarthur on 5/12/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    func sizeClass() -> (vertical: UIUserInterfaceSizeClass, horizontal: UIUserInterfaceSizeClass) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let window: UIWindow = appDelegate.window!
        let vSizeClass: UIUserInterfaceSizeClass!
        let hSizeClass: UIUserInterfaceSizeClass!
        
        hSizeClass = window.traitCollection.horizontalSizeClass
        vSizeClass = window.traitCollection.verticalSizeClass
        
        return (vertical: vSizeClass, horizontal: hSizeClass)
    }
}

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    var manuallyHandleSecondaryViewController = false
    var forwardDelegate: UISplitViewControllerDelegate? = nil
    
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

        if (splitViewController.traitCollection.horizontalSizeClass == .compact) && Display.isIphonePlus() {

            //this is for iphone plus to prepare it for a landscape rotation, otherwise it will crash on landscape rotation
            //in the delegate method below, separateSecondaryFrom, we handle the rotation to landscape
            //every other size class works fine out of the box and needs no extra help
            //http://stackoverflow.com/questions/37578425/iphone-6-plus-uisplitviewcontroller-crash-with-recursive-canbecomedeepestunambi
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
        }
        
        // we did not handle the "show detail", so split view controller,
        // please do your default behavior
        return false
    }

    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        
        guard manuallyHandleSecondaryViewController == true else {
            return nil
        }
        
        if splitViewController.traitCollection.horizontalSizeClass == .regular {
            
            if let tabBarController = splitViewController.viewControllers.first as? UITabBarController {
                if let masterNavController = tabBarController.viewControllers?.first as? UINavigationController {
                    let sb = self.storyboard
                    let detailNavController: UINavigationController = sb?.instantiateViewController(withIdentifier: "movieDetailScene") as! UINavigationController

                    if let presentedVC = masterNavController.popViewController(animated: false) {
                        
                        detailNavController.viewControllers = [presentedVC]
                        manuallyHandleSecondaryViewController = false

                        return detailNavController
                    }
                }
            }
        }
        
        return nil
    }
    
    func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewControllerDisplayMode {
        guard self.forwardDelegate != nil else {
            return .automatic
        }
        return (self.forwardDelegate?.targetDisplayModeForAction!(in: svc))!
    }
    
}
