//
//  BaseViewController.swift
//  MovieLab
//
//  Created by aarthur on 5/12/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    public var shouldCollapseDetailViewController: Bool = true

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.sizeClass().horizontal == .regular {
            self.navigationController?.topViewController!.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        }
    }

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
