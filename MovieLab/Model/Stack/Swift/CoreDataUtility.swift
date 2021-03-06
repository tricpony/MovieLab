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

    class func updateRequest<T>(_ request: NSFetchRequest<T>, query: String) -> NSFetchRequest<T> {
        let predicateC: NSPredicate = NSPredicate(format: "title CONTAINS[c] %@", query)
        let sortOrders = [NSSortDescriptor(key: "title", ascending: true)]
        
        request.predicate = predicateC
        request.sortDescriptors = sortOrders
        return request
    }

    class func fetchRequest(forMovieIDs: Array<Int>, ctx: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        var request: NSFetchRequest<NSFetchRequestResult>? = nil;
        let predicate: NSPredicate = NSPredicate(format: "(%K IN %@)", "movieID", forMovieIDs);
        let sortOrder: NSSortDescriptor = NSSortDescriptor.init(key: "title", ascending: true)
        let sortOrders = [sortOrder]
        
        request = fetchRequest("Movie", ctx, predicate, sortOrders)
        return request!
    }
    
    class func fetchedRequestForFavorites<T>(ctx: NSManagedObjectContext) -> NSFetchRequest<T> {
        let predicate: NSPredicate = equalPredicate(key: "isFavorite", value: 1)
        let sortOrder: NSSortDescriptor = NSSortDescriptor.init(key: "title", ascending: true)
        let sortOrders = [sortOrder]
        
        let request = NSFetchRequest<T>.init(entityName:"Movie")
        request.predicate = predicate
        request.sortDescriptors = sortOrders
        return request
    }
    
    class func fetchGenreCount(ctx: NSManagedObjectContext)->Int {
        let entity = NSEntityDescription.entity(forEntityName: "Genre", in: ctx)
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: (entity?.name)!)
        var count: Int!
        
        do {
            try count = ctx.count(for: request)

        } catch {
            count = 0
        }

        return count
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
