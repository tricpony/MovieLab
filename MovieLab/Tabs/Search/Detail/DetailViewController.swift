//
//  DetailViewController.swift
//  MovieLab
//
//  Created by aarthur on 5/11/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import UIKit

class DetailViewController: BaseViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var overViewLabel: UILabel!
    var managedObjectContext: NSManagedObjectContext? = nil
    public var movie: Movie? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.managedObjectContext = CoreDataStack.sharedInstance().mainContext
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.overViewLabel.text = self.movie?.overview
    }

    @IBAction func toggleStatusFavorite(_ sender: Any) {
        
        if movie?.isFavorite == true {
            movie?.isFavorite = false
        }else{
            movie?.isFavorite = true
        }
        CoreDataStack.sharedInstance().persistContext(self.managedObjectContext, wait: true)
    }
    
}
