//
//  Genre+CoreDataClass.swift
//  
//
//  Created by aarthur on 5/9/17.
//
//

import Foundation
import CoreData

@objc(Genre)
public class Genre: NSManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setValue(NSDate(), forKey:"createDate")
    }

}
