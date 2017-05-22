//
//  Movie+CoreDataProperties.swift
//  
//
//  Created by aarthur on 5/21/17.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var backdropPath: String?
    @NSManaged public var createDate: NSDate?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var movieID: Int32
    @NSManaged public var overview: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var title: String?
    @NSManaged public var genres: NSSet?
    @NSManaged public var cast: NSSet?

}

// MARK: Generated accessors for genres
extension Movie {

    @objc(addGenresObject:)
    @NSManaged public func addToGenres(_ value: Genre)

    @objc(removeGenresObject:)
    @NSManaged public func removeFromGenres(_ value: Genre)

    @objc(addGenres:)
    @NSManaged public func addToGenres(_ values: NSSet)

    @objc(removeGenres:)
    @NSManaged public func removeFromGenres(_ values: NSSet)

}

// MARK: Generated accessors for cast
extension Movie {

    @objc(addCastObject:)
    @NSManaged public func addToCast(_ value: Actor)

    @objc(removeCastObject:)
    @NSManaged public func removeFromCast(_ value: Actor)

    @objc(addCast:)
    @NSManaged public func addToCast(_ values: NSSet)

    @objc(removeCast:)
    @NSManaged public func removeFromCast(_ values: NSSet)

}
