//
//  DetailViewController.swift
//  MovieLab
//
//  Created by aarthur on 5/11/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

let COLLECTION_VIEW_BORDER_SIZE: CGFloat = 5.0

class DetailViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISplitViewControllerDelegate {

    @IBOutlet weak var favoritesNavBarItem: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    var managedObjectContext: NSManagedObjectContext? = nil
    public var movie: Movie? = nil
    var rxIsFavorite = BehaviorRelay<Bool>(value: false)
    let disposeBag = DisposeBag()

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
            let searchVC: SearchPanelViewController? = self.searchViewController()
            
            guard searchVC != nil else {
                return
            }
            if let indexPath = searchVC?.tableView.indexPathForSelectedRow {
                let movie: Movie? = searchVC?.fetchedResultsController.object(at: indexPath)

                self.movie = movie
            }
        }
        self.loadCast()
        self.rxIsFavorite.accept(movie?.isFavorite ?? false)
        self.registerObservableIsFavorite()
        
        if (Display.isIphone() == false) && (self.splitViewController != nil) {
            (self.splitViewController as! SplitViewController).forwardDelegate = self
        }
        device = UIDevice.current
        device.beginGeneratingDeviceOrientationNotifications()
        self.registerUIAssets()
        self.collectionView.backgroundColor = UIColor.clear
        self.managedObjectContext = CoreDataStack.sharedInstance().mainContext
        
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let scrollDirection = expressedScrollViewDirection()
            layout.scrollDirection = scrollDirection
        }
        
        if Display.isIphone() {
            var done: UIBarButtonItem
            
            //on the non-plus phone size class the split view detail expands as a modal, presenting buttom to top
            //unclear if this is caused by a flaw in my code or Apple or if it is expected behavior
            //but I could never force a normal push navigation without breaking another size class
            //consequently, unless we add this button there is no way back to the master view controller
            done = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(DetailViewController.dismissCompactModal))
            self.navigationItem.leftBarButtonItem = done
        }

    }

    func loadCast() {
        
        guard self.movie != nil else {
            return
        }
        guard self.movie?.cast?.count == 0 else {
            return
        }
        
        let serviceRequest = RKNetworkClient();
        let castAsNSNumber = NSNumber(value: (self.movie?.movieID)!)

        serviceRequest.performNetworkCastFetch(matchingMovieID: castAsNSNumber, successBlock: { results in

            for _actor in results! {
                let actor: Actor = _actor as! Actor
                
                self.movie?.addToCast(actor)
                actor.movieID = (self.movie?.movieID)!
            }
            CoreDataStack.sharedInstance().persistContext(self.managedObjectContext, wait: true)
            self.collectionView.reloadItems(at: [IndexPath.init(row: 1, section: 0)])
            print("Service Passed")
        }, failureBlock:{ error in
            print("Service Call Failed: \(String(describing: error?.localizedDescription))")
        })
    
    }
    
    @objc func dismissCompactModal() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func toggleStatusFavorite(_ sender: Any) {
        
        if movie?.isFavorite == true {
            movie?.isFavorite = false
        }else{
            movie?.isFavorite = true
        }
        self.rxIsFavorite.accept(movie?.isFavorite ?? false)
        CoreDataStack.sharedInstance().persistContext(self.managedObjectContext, wait: true)
    }
    
    func searchViewController() -> SearchPanelViewController? {
        let tabVC: UITabBarController
        var navVC: UINavigationController
        var searchVC: SearchPanelViewController? = nil
        
        if self.splitViewController?.viewControllers[0] is UITabBarController {
            tabVC = (self.splitViewController?.viewControllers[0] as? UITabBarController)!
            navVC = (tabVC.viewControllers![0] as? UINavigationController)!
            searchVC = (navVC.viewControllers[0] as? SearchPanelViewController)!
        }
        if self.splitViewController?.viewControllers[0] is UINavigationController {
            navVC = (self.splitViewController?.viewControllers[0] as? UINavigationController)!
            
            if navVC.viewControllers[0] is SearchPanelViewController {
                searchVC = (navVC.viewControllers[0] as? SearchPanelViewController)!
            }
        }

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
    
    func expressedScrollViewDirection()->UICollectionViewScrollDirection {
        let orientation: UIDeviceOrientation = UIDevice.current.orientation

        if (orientation.isLandscape) {
            return .horizontal;
        }
        return .vertical
    }
    
    // MARK: - RxSwift

    private func registerObservableIsFavorite() {
        self.rxIsFavorite.asObservable()
            .subscribe(onNext: {
                isFavorite in

                if isFavorite == true {
                    self.favoritesNavBarItem.image = UIImage.init(named: "star-filled")
                }else{
                    self.favoritesNavBarItem.image = UIImage.init(named: "star-empty")
                }
            
            })
            .disposed(by: disposeBag)
    }

    // MARK: - UIContentContainer
    
    //triggered when the device rotates for all platforms
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard self.collectionView != nil else {
            return
        }
        
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let scrollDirection = expressedScrollViewDirection()
            layout.scrollDirection = scrollDirection
        }
    }
    
    //triggered when size class changes - therefore never called for iPad
//    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//    }
    
    // MARK: - UICollectionViewDataSource

    func cellIdentifier(_ atIndexPath: IndexPath) -> String {
        return ((atIndexPath.row == 0) ? POSTER_COLLECTION_CELL_ID : DETAILS_COLLECTION_CELL_ID)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ((self.movie == nil) ? 0:2)
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
        let fullSize: CGSize = self.view.bounds.size
        
        guard fullSize.height > 0 else {
            return CGRect.zero.size
        }
        
        var splitSize: CGSize!
        var h: CGFloat!
        var w: CGFloat!
        let device: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = device.orientation
        let sizeTrait = self.sizeClass()
        var tabBar: UITabBar? = self.tabBar()
        let navBar = self.navigationController?.navigationBar
        var heightOffset: CGFloat = (navBar?.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        
        if ((sizeTrait.vertical == .regular) && (sizeTrait.horizontal == .regular)) {
            tabBar = nil
        }
        
        if (tabBar != nil) {
            heightOffset += (tabBar?.frame.size.height)!
        }
        
        if (orientation == .landscapeRight) || (orientation == .landscapeLeft) {
            h = (fullSize.height - (COLLECTION_VIEW_BORDER_SIZE * 2.0)) - heightOffset
            w = (fullSize.width - (COLLECTION_VIEW_BORDER_SIZE * 2.0))/2.0
        }else{
            
            h = ((fullSize.height - heightOffset)/2.0) - (COLLECTION_VIEW_BORDER_SIZE * 2.0)
            w = fullSize.width - (COLLECTION_VIEW_BORDER_SIZE * 2.0)
        }
        splitSize = CGSize.init(width: w, height: h)
        
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

    // MARK: - UISplitViewControllerDelegate

    func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewControllerDisplayMode {
        if svc.displayMode == .allVisible {
            
            //this has the side effect of resizing label fonts
            if Display.isIphone() == false {
                self.collectionView.reloadData()
            }
        }
        return .automatic
    }

}
