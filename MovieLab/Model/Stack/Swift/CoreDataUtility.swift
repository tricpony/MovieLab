//
//  CoreDataUtility.swift
//  MovieLab
//
//  Created by aarthur on 5/10/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import Foundation

class CoreDataUtility {
    
    class func fetchRequest(_ entity: String,
                            _ ctx: NSManagedObjectContext,
                            _ predicate: NSPredicate?,
                            _ sortDescriptors: Array<Any>?) -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName:entity)
        
        if predicate != nil {
            request.predicate = predicate
        }
        
        if sortDescriptors != nil {
            request.sortDescriptors = sortDescriptors as? [NSSortDescriptor]
        }
        
        return request
    }
    
    class func fetchedRequest(query: String, ctx: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        var request: NSFetchRequest<NSFetchRequestResult>? = nil
        let predicateC: NSPredicate = NSPredicate(format: "title contains[c] %@", query)
        var predicateV: NSPredicate
        var predicateVV: NSPredicate
        let sortOrder: NSSortDescriptor = NSSortDescriptor.init(key: "title", ascending: true)
        let sortOrders = [sortOrder]
        var strArray: Array<String>
        var predArray: Array<NSPredicate> = Array()
        
        predicateV = NSPredicate(format: "overview contains[c] %@", query)
        predicateV = NSCompoundPredicate.init(orPredicateWithSubpredicates: [predicateC, predicateV])
        strArray = query.characters.split(separator: " ").map(String.init)
        
        for str in strArray where strArray.count > 1 {
            predArray.append(NSPredicate(format: "overview contains[c] %@", str))
        }
        if strArray.count > 1 {
            predicateVV = NSCompoundPredicate.init(orPredicateWithSubpredicates:predArray)
            predicateV = NSCompoundPredicate.init(orPredicateWithSubpredicates: [predicateV, predicateVV])
        }
        
        request = fetchRequest("Movie", ctx, predicateV, sortOrders)
        return request!
    }
    
    class func fetchRequest(forMovieIDs: Array<Int>, ctx: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        var request: NSFetchRequest<NSFetchRequestResult>? = nil;
        let predicate: NSPredicate = NSPredicate(format: "(%K IN %@)", "movieID", forMovieIDs);
        let sortOrder: NSSortDescriptor = NSSortDescriptor.init(key: "title", ascending: true)
        let sortOrders = [sortOrder]
        
        request = fetchRequest("Movie", ctx, predicate, sortOrders)
        return request!
    }
    
    class func fetchedRequestForFavorites(ctx: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        var request: NSFetchRequest<NSFetchRequestResult>? = nil
        let predicateC: NSPredicate = equalPredicate(key: "isFavorite", value: 1)
        let sortOrder: NSSortDescriptor = NSSortDescriptor.init(key: "title", ascending: true)
        let sortOrders = [sortOrder]
        
        request = fetchRequest("Movie", ctx, predicateC, sortOrders)
        return request!
    }
    
    // MARK: - Pre-fabbed predicates
    
    class func equalPredicate(key: String, value: Any) -> NSPredicate {
        let lhs: NSExpression = NSExpression.init(forKeyPath: key)
        let rhs: NSExpression = NSExpression.init(forConstantValue: value)
        let q: NSPredicate = NSComparisonPredicate.init(leftExpression: lhs,
                                                        rightExpression: rhs,
                                                        modifier: NSComparisonPredicate.Modifier.direct,
                                                        type: NSComparisonPredicate.Operator.equalTo,
                                                        options: NSComparisonPredicate.Options.diacriticInsensitive)
        
        return q
    }


}
