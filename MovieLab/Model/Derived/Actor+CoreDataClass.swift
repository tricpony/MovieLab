//
//  Actor+CoreDataClass.swift
//  
//
//  Created by aarthur on 5/21/17.
//
//

import Foundation
import CoreData

@objc(Actor)
public class Actor: NSManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setValue(NSDate(), forKey:"createDate")
    }

}
