//
//  DetailsCollectionViewCell.swift
//  MovieLab
//
//  Created by aarthur on 5/13/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import UIKit
import RxSwift

let DETAILS_COLLECTION_CELL_ID = "DETAILS_COLLECTION_CELL_ID"

protocol MovieDataProtocol {
    func loadData(_ movie: Movie)
}
class DetailsCollectionViewCell: UICollectionViewCell, MovieDataProtocol {

    @IBOutlet weak var castHorizontalLineView: HorizontalLineView!
    @IBOutlet weak var genreHorizontalLineView: HorizontalLineView!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var overViewHeaderBackgroundView: UIView!
    @IBOutlet weak var productionNotesLabel: UILabel!
    @IBOutlet weak var headerBackgroundView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var topCanvasHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topCanvas: HorizontalLineView!
    @IBOutlet weak var bottomCanvas: HorizontalLineView!
    @IBOutlet weak var overViewLabel: UILabel!
    
    @IBOutlet weak var castLabel: UILabel!
    @IBOutlet weak var actorLabelOne: UILabel!
    @IBOutlet weak var actorLabelTwo: UILabel!
    @IBOutlet weak var actorLabelThree: UILabel!
    @IBOutlet weak var actorLabelFour: UILabel!
    @IBOutlet weak var actorLabelFive: UILabel!
    @IBOutlet weak var actorLabelSix: UILabel!
    @IBOutlet weak var actorFourWidthConstraint: NSLayoutConstraint!
    
    var movie: Movie!
    var originalWidthConstraintConstant: CGFloat = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyShadow()
        self.headerLabel.textColor = UIColor.init(red: 65.0/255.0, green: 122.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        self.productionNotesLabel.textColor = UIColor.init(red: 65.0/255.0, green: 122.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        self.originalWidthConstraintConstant = self.actorFourWidthConstraint.constant
        
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
    
    // MARK: - UI Setup

    func clearAllActorLabels() {
        let labelArray = [self.actorLabelOne,self.actorLabelTwo,self.actorLabelThree,self.actorLabelFour,self.actorLabelFive,self.actorLabelSix];
        
        for nextLabel in labelArray {
            nextLabel?.textColor = UIColor.white
            nextLabel?.text = ""
        }
    }

    func changeFontSize(forLabels: Array<UILabel>, byHowMuch: Float) {
        
        for nextLabel in forLabels where (Display.isIphonePlus() || Display.isIphone()) {
            let font = nextLabel.font
            var smallerFont: UIFont
            
            smallerFont = UIFont.init(name: (font?.fontName)!, size: (font?.pointSize)! - 5.0)!
            nextLabel.font = smallerFont
        }

    }
    
    func populateActorLabels() {
        var labelArray = [self.actorLabelOne,self.actorLabelTwo,self.actorLabelThree,self.actorLabelFour,self.actorLabelFive,self.actorLabelSix];
        var index = 0

        if Display.isIphone() == false {
            let orientation: UIDeviceOrientation = UIDevice.current.orientation
            
            self.actorFourWidthConstraint.constant = (orientation.isLandscape == true) ? 0.0 : self.originalWidthConstraintConstant
        }
        
        self.clearAllActorLabels()
        let orderedCast: Array<Actor> = self.movie.orderedCast()
        
        for nextActor in orderedCast where (labelArray.count > index) {
            let nextLabel: UILabel = labelArray[index]!
            
            nextLabel.text = nextActor.name
            index += 1
        }
        let sizeClass = BaseViewController.sizeClass()
        
        if (sizeClass.vertical == .compact) && (sizeClass.horizontal == .regular) {
            labelArray.append(self.productionNotesLabel);
            self.changeFontSize(forLabels: labelArray as! Array<UILabel>, byHowMuch: -5.0)
        }
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
        
        self.genreHorizontalLineView.backgroundColor = UIColor.lightGray
        self.genreHorizontalLineView.distanceFromBottom = 0.20
        self.genreHorizontalLineView.strokeColor = UIColor.black
        self.genreHorizontalLineView.strokeWidth = 1.0
        self.genreHorizontalLineView.xOffset = 5.0
        
        self.castHorizontalLineView.backgroundColor = UIColor.lightGray
        self.castHorizontalLineView.distanceFromBottom = 0.20
        self.castHorizontalLineView.strokeColor = UIColor.black
        self.castHorizontalLineView.strokeWidth = 1.0
        self.castHorizontalLineView.xOffset = 5.0
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
        
        if (self.movie.cast?.count)! > 0 {
            self.clearAllActorLabels()
            self.populateActorLabels()
        }
        let sizeClass = BaseViewController.sizeClass()
        
        if (sizeClass.vertical == .compact) && (sizeClass.horizontal == .regular) {
            self.changeFontSize(forLabels: [self.overViewLabel], byHowMuch: -5.0)
        }
    }

}
