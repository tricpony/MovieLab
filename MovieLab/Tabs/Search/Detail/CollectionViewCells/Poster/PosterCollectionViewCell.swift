//
//  PosterCollectionViewCell.swift
//  MovieLab
//
//  Created by aarthur on 5/13/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import UIKit

let POSTER_COLLECTION_CELL_ID = "POSTER_COLLECTION_CELL_ID"

class PosterCollectionViewCell: UICollectionViewCell, MovieDataProtocol {

    @IBOutlet weak var posterImageView: UIImageView!
    var movie: Movie!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyShadow()
    }

    func loadData(_ movie: Movie) {
        self.movie = movie
        self.loadPosterImage()
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
            var imgData: NSData!
            
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

}
