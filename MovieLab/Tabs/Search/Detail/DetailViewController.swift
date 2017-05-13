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
        self.loadPosterImage()
    }

    @IBAction func toggleStatusFavorite(_ sender: Any) {
        
        if movie?.isFavorite == true {
            movie?.isFavorite = false
        }else{
            movie?.isFavorite = true
        }
        CoreDataStack.sharedInstance().persistContext(self.managedObjectContext, wait: true)
    }
    
    func loadPosterImage() {
        var posterPath: String
        var posterURLString: String
        
        guard (self.movie?.posterPath != nil) else {
            return
        }
        posterPath = (self.movie?.posterPath)!
        posterURLString = "\(API_BaseMoviePosterArtURL)\(posterPath)"

        DispatchQueue.global(qos: .background).async {
            
            let imageURL: URL = URL.init(string: posterURLString)!
            var imgData: NSData!// = NSData.init(contentsOf: imageURL, options: .alwaysMapped)
            
            do {
                try imgData = NSData.init(contentsOf: imageURL, options: .alwaysMapped)
                DispatchQueue.main.async {
                    if (imgData != nil) {
                        self.posterImageView.image = UIImage.init(data: imgData as Data)
                    }
                }
            } catch {
                
            }
        }
        
    }

//        DispatchQueue.global(qos: .userInitiated).async {
//        DispatchQueue.global(qos: .background).async {
//
//            let imageURL: URL = URL.init(string: imageURLString)!
//            var imgData: NSData!// = NSData.init(contentsOf: imageURL, options: .alwaysMapped)
//
//            try imgData = NSData.init(contentsOf: imageURL, options: .alwaysMapped)
//            
//            DispatchQueue.main.async {
//                if imgData {
//                    self.posterImageView.image = UIImage.init(data: imgData)
//                }
//            }
//        }

//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            let imageURL: NSURL = NSURL.init(string: imageURLString)
//            var imgData: NSData = NSData.init(contentsOf: imageURL)
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (imgData)
//                {
//                    //Load the data into an UIImage:
//                    UIImage *image = [UIImage imageWithData:imgData];
//                    
//                    //Check if your image loaded successfully:
//                    if (image)
//                    {
//                        yourImageView.image = image;
//                    }
//                    else
//                    {
//                        //Failed to load the data into an UIImage:
//                        yourImageView.image = [UIImage imageNamed:@"no-data-image.png"];
//                    }
//                }
//                else
//                {
//                    //Failed to get the image data:
//                    yourImageView.image = [UIImage imageNamed:@"no-data-image.png"];
//                }
//                });
//            });
//
//    }
    
}
