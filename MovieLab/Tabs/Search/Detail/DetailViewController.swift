//
//  DetailViewController.swift
//  MovieLab
//
//  Created by aarthur on 5/11/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
