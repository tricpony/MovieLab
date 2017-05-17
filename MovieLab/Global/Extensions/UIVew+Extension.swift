//
//  UIVew+Extension.swift
//  MovieLab
//
//  Created by aarthur on 5/14/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import Foundation

extension UIView
{

    //for debugging
    func enableBorders() {
        let layer = self.layer
        
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1.0
    }
    
    func applyBlur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
    }
    
    //this belongs in a UIColor extension
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func applyShadow () {
        let layer = self.layer

        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize.init(width: 1, height: 1)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 3.0
        layer.shouldRasterize = true
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1.7
        layer.cornerRadius = 6.25
        layer.rasterizationScale = UIScreen.main.scale
    }
}
