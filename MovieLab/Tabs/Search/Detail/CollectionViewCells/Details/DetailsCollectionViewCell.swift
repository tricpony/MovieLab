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

    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var overViewHeaderBackgroundView: UIView!
    @IBOutlet weak var overViewHeaderLabel: UILabel!
    @IBOutlet weak var headerBackgroundView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var topCanvasHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topCanvas: HorizontalLineView!
    @IBOutlet weak var bottomCanvas: HorizontalLineView!
    @IBOutlet weak var overViewLabel: UILabel!
    var movie: Movie!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyShadow()
        self.headerLabel.textColor = UIColor.init(red: 65.0/255.0, green: 122.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        self.overViewHeaderLabel.textColor = UIColor.init(red: 65.0/255.0, green: 122.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        
        var layer: CALayer = self.headerBackgroundView.layer
        
        layer.borderWidth = 1.0
        layer.cornerRadius = 12.25
        
        //OldLace
        //http://www.blooberry.com/indexdot/color/x11makerFrameNS.htm
        layer.backgroundColor = UIColor.hexStringToUIColor(hex: "#FDF5E6").cgColor
        
        layer = self.overViewHeaderBackgroundView.layer
        layer.borderWidth = 1.0
        layer.cornerRadius = 12.25
        
        //OldLace
        //http://www.blooberry.com/indexdot/color/x11makerFrameNS.htm
        layer.backgroundColor = UIColor.hexStringToUIColor(hex: "#FDF5E6").cgColor
    }
    
    func configureCanvas() {
        self.topCanvas.backgroundColor = UIColor.darkGray
        self.topCanvas.yPosition = self.topCanvasHeightConstraint.constant + 3.0
        self.topCanvas.strokeColor = UIColor.white
        self.topCanvas.strokeWidth = 2.0
        self.topCanvas.xOffset = 10.0
        
        self.bottomCanvas.distanceFromBottom = 1.0
        self.bottomCanvas.strokeColor = UIColor.darkGray
        self.bottomCanvas.strokeWidth = 0
        self.bottomCanvas.xOffset = 12.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.configureCanvas()
    }
    
    // MARK: - MovieDataProtocol
    
    func loadData(_ movie: Movie) {
        self.movie = movie
        self.overViewLabel.text = movie.overview
        self.titleLabel.text = movie.title
        
        
        if (self.movie.genres?.anyObject()) != nil {
            let genre: Genre = self.movie.genres?.anyObject() as! Genre
            
            self.genre.text = genre.name.characters.count == 0 ? "Unknown":genre.name
        }
        
        if Display.isIphonePlus() || Display.isIphone() {
            let font = self.overViewLabel.font
            var smallerFont: UIFont
            
            smallerFont = UIFont.init(name: (font?.fontName)!, size: (font?.pointSize)! - 5.0)!
            self.overViewLabel.font = smallerFont
        }
    }

}
