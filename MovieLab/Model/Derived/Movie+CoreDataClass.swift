//
//  Movie+CoreDataClass.swift
//  
//
//  Created by aarthur on 5/9/17.
//
//

import Foundation
import CoreData

@objc(Movie)
public class Movie: NSManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setValue(NSDate(), forKey:"createDate")
    }
}
