//
//  SplitViewControllerDetail.swift
//  MovieLab
//
//  Created by aarthur on 1/17/21.
//  Copyright © 2021 Gigabit LLC. All rights reserved.
//

import Foundation

protocol SplitViewControllerDetail where Self: UIViewController {
    var detailVC: UINavigationController? { set get }
    func syncSplitViewControllerSecondary()
}

extension SplitViewControllerDetail {
    
    /// Keep primary and secondary view controllers in sync when switching tabs.
    func syncSplitViewControllerSecondary() {
        if splitViewController?.isCollapsed == false {
            guard let detail = detailVC else {
                let sb = UIStoryboard(name: "Detail", bundle: nil)
                let placeholder = sb.instantiateViewController(withIdentifier: "PlaceholderScene")
                (self.splitViewController as? SplitViewController)?.showDetailViewController(placeholder, sender: nil)
                return }
            (self.splitViewController as? SplitViewController)?.showDetailViewController(detail, sender: nil)
        }
    }
}
