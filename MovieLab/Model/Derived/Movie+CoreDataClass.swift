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
    
    func orderedCast()->Array<Actor> {
        let desc: NSSortDescriptor = NSSortDescriptor.init(key: "order", ascending: true)
        return self.cast?.sortedArray(using: [desc]) as! Array<Actor>
    }
    
}
