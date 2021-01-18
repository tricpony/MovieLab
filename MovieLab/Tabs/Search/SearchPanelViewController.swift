//
//  SearchPanelViewController.swift
//  MovieLab
//
//  Created by aarthur on 5/10/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import UIKit
import RxSwift

class SearchPanelViewController: BaseViewController, UISearchBarDelegate, SplitViewControllerDetail {
    var detailVC: UINavigationController? = nil
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var managedObjectContext = CoreDataStack.sharedInstance().mainContext
    let disposeBag = DisposeBag()
    var fetchRequest = NSFetchRequest<Movie>.init(entityName:"Movie")
    lazy var tableRxData: RxFetchedResultsCommand<Movie> = {
        let data = RxFetchedResultsCommand<Movie>(fetchRequest: fetchRequest,
                                                  context: CoreDataStack.sharedInstance().mainContext,
                                                  shouldObserveChanges: false)
        data.bind(to: tableView.rx.items(cellIdentifier: "movieCell")) { index, movie, cell in
            cell.textLabel?.text = movie.title
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        .disposed(by: disposeBag)
        return data
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preFillGenreTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (splitViewController as? SplitViewController)?.isOnFavorites = false
        syncSplitViewControllerSecondary()
    }

    // MARK: - Service

    @IBAction func performSearch(_ sender: Any) {
        guard let query: String = self.searchBar.text, !query.isEmpty else { return }
        let searchArgs = ["query" : query]
        let serviceRequest = RKNetworkClient();
        
        self.searchBar.resignFirstResponder()
        serviceRequest.performNetworkMovieFetch(matchingParameters: searchArgs as [AnyHashable : Any], successBlock: { [unowned self] results in
            refreshResults()
        }, failureBlock:{ error in
            print("Service Call Failed: \(String(describing: error?.localizedDescription))")
        })
    }
    
    func preFillGenreTable() {
        DispatchQueue.global(qos: .background).async {
            var genreCount = 0
            genreCount = CoreDataUtility.fetchGenreCount(ctx: self.managedObjectContext!)
            if genreCount == 0 {
                let serviceRequest = RKNetworkClient();
                serviceRequest.performNetworkMovieGenreFetchWithsuccessBlock(nil, failureBlock: nil)
            }
        }
    }
    
    // MARK: - RxSwift

    func refreshResults() {
        guard let arg = searchBar.text else { return }
        tableRxData.refreshResults(query: arg)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.performSearch(searchBar)
    }

    // MARK: - Storyboard

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "movieDetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                guard let frc = tableRxData.fetchedResultsController else { return }
                let movie = frc.object(at: indexPath)
                guard let vc = (segue.destination as? UINavigationController)?.topViewController as? DetailViewController else { return }
                if splitViewController?.isCollapsed == false {
                    detailVC = vc.navigationController
                }
                vc.movie = movie
                vc.navigationItem.title = movie.title
                vc.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                vc.navigationItem.leftItemsSupplementBackButton = true
           }
        }
    }
}

