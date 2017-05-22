//
//  Actor+CoreDataProperties.swift
//  
//
//  Created by aarthur on 5/21/17.
//
//

import Foundation
import CoreData


extension Actor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Actor> {
        return NSFetchRequest<Actor>(entityName: "Actor")
    }

    @NSManaged public var createDate: NSDate?
    @NSManaged public var castID: Int32
    @NSManaged public var actorID: Int32
    @NSManaged public var movieID: Int32
    @NSManaged public var charactor: String?
    @NSManaged public var creditID: Int32
    @NSManaged public var name: String?
    @NSManaged public var order: Int16
    @NSManaged public var profilePath: String?
    @NSManaged public var movies: NSSet?

}

// MARK: Generated accessors for movies
extension Actor {

    @objc(addMoviesObject:)
    @NSManaged public func addToMovies(_ value: Movie)

    @objc(removeMoviesObject:)
    @NSManaged public func removeFromMovies(_ value: Movie)

    @objc(addMovies:)
    @NSManaged public func addToMovies(_ values: NSSet)

    @objc(removeMovies:)
    @NSManaged public func removeFromMovies(_ values: NSSet)

}
