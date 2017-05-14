//
//  DetailViewController.swift
//  MovieLab
//
//  Created by aarthur on 5/11/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import UIKit

let COLLECTION_VIEW_BORDER_SIZE: CGFloat = 5.0

class DetailViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    var managedObjectContext: NSManagedObjectContext? = nil
    public var movie: Movie? = nil
    
    func registerUIAssets() {
        var nib: UINib!
        
        nib = UINib.init(nibName: "DetailsCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: DETAILS_COLLECTION_CELL_ID)
        nib = UINib.init(nibName: "PosterCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: POSTER_COLLECTION_CELL_ID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var device: UIDevice!
        
        if self.movie == nil {
            let searchVC: SearchPanelViewController = self.searchViewController()
            
            self.movie = searchVC.selectedMovie
        }
        
        device = UIDevice.current
        device.beginGeneratingDeviceOrientationNotifications()
        self.registerUIAssets()
        self.collectionView.backgroundColor = UIColor.clear
        self.managedObjectContext = CoreDataStack.sharedInstance().mainContext
    }

    @IBAction func toggleStatusFavorite(_ sender: Any) {
        
        if movie?.isFavorite == true {
            movie?.isFavorite = false
        }else{
            movie?.isFavorite = true
        }
        CoreDataStack.sharedInstance().persistContext(self.managedObjectContext, wait: true)
    }
    
    func searchViewController() -> SearchPanelViewController {
        let tabVC: UITabBarController = (self.splitViewController?.viewControllers[0] as? UITabBarController)!
        let navVC: UINavigationController = (tabVC.viewControllers![0] as? UINavigationController)!
        let searchVC: SearchPanelViewController = (navVC.viewControllers[0] as? SearchPanelViewController)!

        return searchVC
    }
    
    func tabBar() -> UITabBar? {

        if self.tabBarController != nil {
            return (self.tabBarController?.tabBar)!
        }
        
        let searchVC: UIViewController? = self.searchViewController()
        if searchVC == nil {
            return nil
        }
        
        return (searchVC?.tabBarController?.tabBar)!
    }
    
    // MARK: - UIInterfaceOrientation
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {

        guard self.collectionView != nil else {
            if newCollection.horizontalSizeClass == .regular {
                self.navigationController?.topViewController!.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            }
            return
        }

        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        
        if (orientation == .landscapeLeft) || (orientation == .landscapeRight) {
            if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
            }
        }else{
            if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .vertical
            }
        }

    }

    // MARK: - UICollectionViewDataSource

    func cellIdentifier(_ atIndexPath: IndexPath) -> String {
        return ((atIndexPath.row == 0) ? POSTER_COLLECTION_CELL_ID : DETAILS_COLLECTION_CELL_ID)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ((self.tabBar() == nil) || (self.movie == nil) ? 0:2)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:MovieDataProtocol!
            
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier(indexPath), for: indexPath) as! MovieDataProtocol
        
        if self.movie != nil {
            cell.loadData(self.movie!)
        }
        
        return cell as! UICollectionViewCell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fullSize: CGSize = UIScreen.main.bounds.size
        var splitSize: CGSize!
        var h: CGFloat!
        var w: CGFloat!
        let device: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = device.orientation
        let tabBar: UITabBar = self.tabBar()!
        
        if (orientation == .landscapeRight) || (orientation == .landscapeLeft) {
            h = fullSize.height - (COLLECTION_VIEW_BORDER_SIZE * 2.0)
            w = (fullSize.width - (COLLECTION_VIEW_BORDER_SIZE * 2.0))/2.0
        }else{
            
            h = fullSize.height/2.0
            w = fullSize.width - (COLLECTION_VIEW_BORDER_SIZE * 2.0)
        }
        splitSize = CGSize.init(width: w, height: h - (tabBar.frame.size.height + 15))
        
        return splitSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return COLLECTION_VIEW_BORDER_SIZE
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: COLLECTION_VIEW_BORDER_SIZE, left: COLLECTION_VIEW_BORDER_SIZE, bottom: COLLECTION_VIEW_BORDER_SIZE, right: COLLECTION_VIEW_BORDER_SIZE)
    }
    
    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

}
