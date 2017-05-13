//
//  SearchPanelViewController.swift
//  MovieLab
//
//  Created by aarthur on 5/10/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import UIKit

class SearchPanelViewController: BaseViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISplitViewControllerDelegate {

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var _fetchedResultsController: NSFetchedResultsController<Movie>? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        let nc = NotificationCenter.default
        self.view.bringSubview(toFront: self.progressBar)
        self.splitViewController?.delegate = self

        self.managedObjectContext = CoreDataStack.sharedInstance().mainContext
        nc.addObserver(self, selector:#selector(SearchPanelViewController.advanceProgressBar), name: NSNotification.Name.VN_IncrementActivityCount, object:nil)
        
        //debug
//        self.searchBar.text = "Dirty Harry"
        self.searchBar.text = "pixar"
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
        let query: String = self.searchBar.text!
        let searchArgs: NSDictionary = [
            "query" : query
        ]
        let serviceRequest = RKNetworkClient();
        
        self.searchBar.resignFirstResponder()
        self.progressBar.alpha = 1
        self.progressBar.setProgress(0, animated: false)
        serviceRequest.performNetworkMovieFetch(matchingParameters: searchArgs as! [AnyHashable : Any], successBlock: { results in
            
            self._fetchedResultsController = nil
            self.tableView.reloadData()
            self.fadeOutProgressBar()

        }, failureBlock:{ error in
            self.fadeOutProgressBar()
            print("Service Call Failed: \(String(describing: error?.localizedDescription))")
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
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let movie: Movie = fetchedResultsController.object(at: indexPath)
        
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle(rawValue: 0)!, reuseIdentifier: "Cell")
        }
        cell?.textLabel!.text = movie.title
        cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.shouldCollapseDetailViewController = false
        
        if self.sizeClass().horizontal == .compact {
            
            let sb: UIStoryboard = self.storyboard!
            let destinationVC: UINavigationController = sb.instantiateViewController(withIdentifier: "movieDetailScene") as! UINavigationController
            var segue: UIStoryboardSegue!
            
            segue = UIStoryboardSegue.init(identifier: "movieDetailSegue", source: self, destination: destinationVC) {
                self.navigationController?.pushViewController(destinationVC.viewControllers[0], animated: true)
            }
            
            self.prepare(for: segue, sender: indexPath)
            segue.perform()
            
        }else{
            
            self.performSegue(withIdentifier: "movieDetailSegue", sender: indexPath)
            
        }
    }
    
    // MARK: - UISplitViewControllerDelegate
    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        
        return self.shouldCollapseDetailViewController
    }

    // MARK: - Storyboard

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc: DetailViewController
        var navVC: UINavigationController
        var movie: Movie
        let indexPath: NSIndexPath = sender as! NSIndexPath
        
        movie = fetchedResultsController.object(at: indexPath as IndexPath)
        navVC = segue.destination as! UINavigationController
        vc = navVC.topViewController as! DetailViewController
        vc.movie = movie;
        vc.title = movie.title
    }

}
