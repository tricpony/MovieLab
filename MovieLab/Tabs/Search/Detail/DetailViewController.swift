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
        collectionView.register(nib, forCellWithReuseIdentifier: DETAILS_COLLECTION_CELL_ID)
        nib = UINib.init(nibName: "PosterCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: POSTER_COLLECTION_CELL_ID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCast()
        rxIsFavorite.accept(movie?.isFavorite ?? false)
        registerObservableIsFavorite()
        
        if (Display.isIphone() == false) && (splitViewController != nil) {
            (splitViewController as! SplitViewController).forwardDelegate = self
        }
        let device = UIDevice.current
        device.beginGeneratingDeviceOrientationNotifications()
        registerUIAssets()
        collectionView.backgroundColor = UIColor.clear
        managedObjectContext = CoreDataStack.sharedInstance().mainContext
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
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
            navigationItem.leftBarButtonItem = done
        }

    }

    func loadCast() {
        guard let movie = movie else { return }
        guard movie.cast?.count == 0 else { return }
        
        // if the cast is empty then we need to do this
        // then save it and we need not do this again
        let serviceRequest = RKNetworkClient();
        let castAsNSNumber = NSNumber(value: (movie.movieID))

        serviceRequest.performNetworkCastFetch(matchingMovieID: castAsNSNumber, successBlock: { [unowned self] results in

            for actor in results! {
                guard let actor = actor as? Actor else { continue }
                movie.addToCast(actor)
                actor.movieID = movie.movieID
            }
            CoreDataStack.sharedInstance().persistContext(managedObjectContext, wait: false)
            DispatchQueue.main.async {
                collectionView.reloadData()
            }
            print("Service Passed")
        }, failureBlock:{ error in
            print("Service Call Failed: \(String(describing: error?.localizedDescription))")
        })
    
    }
    
    @objc func dismissCompactModal() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func toggleStatusFavorite(_ sender: Any) {
        movie?.isFavorite.toggle()
        rxIsFavorite.accept(movie?.isFavorite ?? false)
        CoreDataStack.sharedInstance().persistContext(managedObjectContext, wait: true)
    }
            
    func expressedScrollViewDirection()->UICollectionView.ScrollDirection {
        let orientation: UIDeviceOrientation = UIDevice.current.orientation

        if (orientation.isLandscape) {
            return .horizontal;
        }
        return .vertical
    }
    
    // MARK: - RxSwift

    private func registerObservableIsFavorite() {
        rxIsFavorite.asObservable()
            .subscribe(onNext: { [unowned self] isFavorite in

                if isFavorite == true {
                    favoritesNavBarItem.image = UIImage(named: "star-filled")
                } else {
                    favoritesNavBarItem.image = UIImage(named: "star-empty")
                }
            
            })
            .disposed(by: disposeBag)
    }

    // MARK: - UIContentContainer
    
    //triggered when the device rotates for all platforms
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard collectionView != nil else { return }
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let scrollDirection = expressedScrollViewDirection()
            layout.scrollDirection = scrollDirection
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
        return ((movie == nil) ? 0:2)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let movie = self.movie else { return UICollectionViewCell() }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier(indexPath), for: indexPath) as? MovieCellProtocol else { return UICollectionViewCell() }
        cell.loadData(movie)
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fullSize: CGSize = view.bounds.size
        
        guard fullSize.height > 0 else {
            return CGRect.zero.size
        }
        
        var splitSize: CGSize!
        var h: CGFloat!
        var w: CGFloat!
        let device: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = device.orientation
        let sizeTrait = sizeClass()
        var tabBar = tabBarController?.tabBar
        let navBar = navigationController?.navigationBar
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

    func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewController.DisplayMode {
        if svc.displayMode == .allVisible {
            
            //this has the side effect of resizing label fonts
            if Display.isIphone() == false {
                collectionView.reloadData()
            }
        }
        return .automatic
    }

}
