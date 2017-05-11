//
//  Movie+CoreDataProperties.swift
//  
//
//  Created by aarthur on 5/9/17.
//
//

import Foundation
import CoreData

extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var createDate: NSDate?
    @NSManaged public var posterPath: String?
    @NSManaged public var overview: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var movieID: Int32
    @NSManaged public var title: String?
    @NSManaged public var backdropPath: String?
    @NSManaged public var genres: NSSet?
    @NSManaged public var isFavorite: Bool

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
