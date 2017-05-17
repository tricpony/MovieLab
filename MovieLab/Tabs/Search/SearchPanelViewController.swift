//
//  SearchPanelViewController.swift
//  MovieLab
//
//  Created by aarthur on 5/10/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import UIKit

class SearchPanelViewController: BaseViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var _fetchedResultsController: NSFetchedResultsController<Movie>? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var serviceCallInFlight: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let nc = NotificationCenter.default
        self.view.bringSubview(toFront: self.progressBar)

        self.managedObjectContext = CoreDataStack.sharedInstance().mainContext
        nc.addObserver(self, selector:#selector(SearchPanelViewController.advanceProgressBar), name: NSNotification.Name.VN_IncrementActivityCount, object:nil)
        
        //debug
//        self.searchBar.text = "Dirty Harry"
//        self.searchBar.text = "pixar"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.tableView.indexPathForSelectedRow != nil {
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: false);
        }
    }
    
    func fadeOutProgressBar() {
    
        UIView.animate(withDuration: 1.5, delay: 0, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.progressBar.alpha = 0
        }, completion: nil)
    }
    
    @IBAction func performSearch(_ sender: Any) {
        
        guard (self.searchBar.text?.characters.count)! > 0 else {
            return
        }
        guard self.serviceCallInFlight == false else {
            return
        }
        let query: String = self.searchBar.text!
        let searchArgs: NSDictionary = [
            "query" : query
        ]
        self.serviceCallInFlight = true
        let serviceRequest = RKNetworkClient();
        
        self.searchBar.resignFirstResponder()
        self.progressBar.alpha = 1
        self.progressBar.setProgress(0, animated: false)
        serviceRequest.performNetworkMovieFetch(matchingParameters: searchArgs as! [AnyHashable : Any], successBlock: { results in
            
            self._fetchedResultsController = nil
            self.tableView.reloadData()
            self.fadeOutProgressBar()
            self.serviceCallInFlight = false

        }, failureBlock:{ error in
            self.fadeOutProgressBar()
            print("Service Call Failed: \(String(describing: error?.localizedDescription))")
            self.serviceCallInFlight = false
        })
    }

    func advanceProgressBar(notice: NSNotification) {
        var downloadSizeSoFar: Int16
        var expectedDownloadSize: Int16
        let userInfo: Dictionary = notice.userInfo!
        
        downloadSizeSoFar = userInfo[VN_TotalBytesWritten] as! Int16
        expectedDownloadSize = userInfo[VN_TotalBytesExpected] as! Int16
        self.progressBar.setProgress(Float(downloadSizeSoFar/expectedDownloadSize), animated: true)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.performSearch(searchBar)
    }

    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Movie> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = CoreDataUtility.fetchedRequest(query: self.searchBar.text!, ctx: self.managedObjectContext!)
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: self.managedObjectContext!,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController as? NSFetchedResultsController<Movie>
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.rectForRow(at: indexPath!)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
        let movie: Movie = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel!.text = movie.title
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }

    // MARK: - Storyboard

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "movieDetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let movie: Movie = fetchedResultsController.object(at: indexPath)
                let vc = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                vc.movie = movie
                vc.navigationItem.title = movie.title
                vc.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                vc.navigationItem.leftItemsSupplementBackButton = true
           }
        }
    }

}

