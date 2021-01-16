//
//  FavoritesTableViewController.swift
//  MovieLab
//
//  Created by aarthur on 5/11/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import UIKit
import RxSwift

class FavoritesTableViewController: UITableViewController {
    var _fetchedResultsController: NSFetchedResultsController<Movie>? = nil
    let disposeBag = DisposeBag()
    var fetchRequest: NSFetchRequest<Movie> = CoreDataUtility.fetchedRequestForFavorites(ctx: CoreDataStack.sharedInstance().mainContext!)
    lazy var tableRxData: RxObservable<Movie> = {
        let data = RxObservable<Movie>(fetchRequest: fetchRequest, context: CoreDataStack.sharedInstance().mainContext)
        data.refreshResults(shouldRefresh: false)
        data.bind(to: tableView.rx.items(cellIdentifier: "movieCell")) { index, movie, cell in
            cell.textLabel?.text = movie.title
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        .disposed(by: disposeBag)
        return data
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = nil
        tableView.dataSource = nil
        _ = tableRxData
        self.clearsSelectionOnViewWillAppear = false

        let sizeClass = BaseViewController.sizeClass()
        
        if (sizeClass.vertical == .regular) && (sizeClass.horizontal == .compact) {
            (self.splitViewController as! SplitViewController).isOnFavorites = true
        }
    }

    // MARK: - Storyboard
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "movieDetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                guard let frc = tableRxData.fetchedResultsController else { return }
                let movie = frc.object(at: indexPath)
                let vc = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                vc.movie = movie
                vc.navigationItem.title = movie.title
                vc.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                vc.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
}
