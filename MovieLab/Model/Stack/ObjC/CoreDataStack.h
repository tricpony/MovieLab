//
//  CoreDataStack.h
//  MovieLab
//
//  Created by aarthur on 5/10/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - API

FOUNDATION_EXPORT NSString * const API_BaseMovieURL;
FOUNDATION_EXPORT NSString * const API_BaseMoviePosterArtURL;

@class NSManagedObjectContext;
@interface CoreDataStack : NSObject
@property (nonatomic, readonly) NSManagedObjectContext *mainContext;
@property (nonatomic, readonly) NSManagedObjectContext *temporaryContext;
@property (nonatomic, readonly) NSManagedObjectContext *childContext;
@property (nonatomic, readonly) NSManagedObjectContext *peerContext;

+ (instancetype)sharedInstance NS_SWIFT_NAME(sharedInstance());
- (void)persistContext:(NSManagedObjectContext *)context wait:(BOOL)wait;

@end
