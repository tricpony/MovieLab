//
//  DetailsCollectionViewCell.swift
//  MovieLab
//
//  Created by aarthur on 5/13/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import UIKit

let DETAILS_COLLECTION_CELL_ID = "DETAILS_COLLECTION_CELL_ID"

protocol MovieDataProtocol {
    func loadData(_ movie: Movie)
}
class DetailsCollectionViewCell: UICollectionViewCell, MovieDataProtocol {

    @IBOutlet weak var overViewLabel: UILabel!
    var movie: Movie!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyShadow()
    }
    
    func loadData(_ movie: Movie) {
        self.movie = movie
        self.overViewLabel.text = movie.overview
    }

}
