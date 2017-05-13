//
//  CoreDataStack.m
//  MovieLab
//
//  Created by aarthur on 5/10/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

#import "CoreDataStack.h"
#import <MagicalRecord/MagicalRecord.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#import <RestKit/RestKit.h>
#pragma clang pop

NSString * const API_BaseMovieURL = @"http://api.themoviedb.org/3/";
NSString * const API_BaseMoviePosterArtURL = @"http://image.tmdb.org/t/p/w500/";

static CoreDataStack *sharedInstance = nil;

//exposing MagicalRecords private methods
@interface NSManagedObjectContext()

+ (void)MR_setRootSavingContext:(NSManagedObjectContext*)context;
+ (void)MR_setDefaultContext:(NSManagedObjectContext*)context;

@end

@interface CoreDataStack ()
{
    NSManagedObjectContext *_privateContext;
    NSManagedObjectContext *_mainContext;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSPersistentStore *_persistentStore;
}

@end

@implementation CoreDataStack

#pragma mark ---- Core Data Stack and Contexts ----

- (void)initializeCoreDataStack
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MovieLab" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    // initialize RestKit
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:API_BaseMovieURL]];
    [RKObjectManager setSharedManager:objectManager];
    objectManager.managedObjectStore = managedObjectStore;
    
    
    
    // Complete Core Data stack initialization
    [managedObjectStore createPersistentStoreCoordinator];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"MovieLab.sqlite"];
    NSString *seedPath = [[NSBundle mainBundle] pathForResource:@"RKSeedDatabase" ofType:@"sqlite"];
    NSError *error = nil;
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:seedPath withConfiguration:nil options:nil error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    //Create the managed object contexts
    [managedObjectStore createManagedObjectContexts];
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    
    //Configure MagicalRecord to use RestKit's core data stack
    [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:managedObjectStore.persistentStoreCoordinator];
    [NSManagedObjectContext MR_setRootSavingContext:managedObjectStore.persistentStoreManagedObjectContext];
    [NSManagedObjectContext MR_setDefaultContext:managedObjectStore.mainQueueManagedObjectContext];
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = managedObjectStore.persistentStoreCoordinator;
    if ( persistentStoreCoordinator == nil )
    {
        [NSException raise:NSMallocException format:@"Failed to initialize persistent store coordinator"];
    }
    _persistentStoreCoordinator = persistentStoreCoordinator;
    
    if ( persistentStore == nil )
    {
        [NSException raise:NSMallocException format:@"Failed to add persistent store. %@", [error localizedDescription]];
    }
    _persistentStore = persistentStore;
    
    _privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_privateContext performBlockAndWait:^{
        
        [_privateContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    }];
    
    _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    //this setting tells core data that if mainContext ever gets a save where
    //there is a conflict between the persistant store and the main context
    //then let the persistant store win, meaning that if another context has
    //saved something to the persistant store, like in a thread, that does
    //not match what mainContext expects it to be then don't crash, just
    //let stay as it already is in the persistant store
    [_mainContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    [_mainContext setParentContext:_privateContext];
    
    MRLogVerbose(@"Core Data stack initialized.");
}

- (NSManagedObjectContext*)mainContext
{
    return _mainContext;
}

/**
 Return mainContext when on main thread, otherwise return RK persistentStoreManagedObjectContext
 **/
- (NSManagedObjectContext*)temporaryContext
{
    if ( [NSThread isMainThread] == YES )
    {
        return [self mainContext];
    }
    
    return [self childContext];
}

/**
 Return a context whose parent is mainContext
 **/
- (NSManagedObjectContext*)childContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    [context setParentContext:[self mainContext]];
    
    return context;
}

/**
 Return a context whose parent is privateContext
 **/
- (NSManagedObjectContext*)peerContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setParentContext:_privateContext];
    
    return context;
}

/**
 Return a context whose parent is the arg context
 **/
- (NSManagedObjectContext*)childContextOfContext:(NSManagedObjectContext *)context
{
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [childContext setParentContext:context];
    
    return childContext;
}

#pragma mark - Save Methods

- (void)persistContext:(NSManagedObjectContext *)context wait:(BOOL)wait
{
    if ([context isEqual:_mainContext] == YES || [context isEqual:_privateContext] == YES)
    {
        [self persist:wait];
    }
    else
    {
        if ([context hasChanges])
        {
            NSError *error = nil;
            BOOL successful = [context save:&error];
            
            if ( successful == NO )
            {
                [NSException raise:NSInternalInconsistencyException
                            format:@"Error saving temporary context: %@\n%@", [error localizedDescription], [error userInfo]];
            }
            
            if ( error != nil )
            {
                MRLogError(@"Error on saving temporaryContext: %@\n%@", [error localizedDescription], [error userInfo]);
            }
            
            [self persist:wait];
        }
    }
}

/**
 This is where the save will eventually reach privateContext which actually connects to the sqlite db
 **/
- (void)persist:(BOOL)wait
{
    if ( _mainContext == nil )
    {
        return;
    }
    
    if ( [_mainContext hasChanges] == YES )
    {
        [_mainContext performBlockAndWait:^{
            NSError *error = nil;
            @try {
                [_mainContext save:&error];
            }
            @catch (NSException * e) {
                MRLogError(@"Error saving mainContext!: %@: %@", [e name], [e reason]);
            }
        }];
    }
    
    void (^savePrivate) (void) = ^ {
        
        NSError *error = nil;
        @try {
            [_privateContext save:&error];
        }
        @catch (NSException * e) {
            MRLogError(@"Error saving privateContext!: %@: %@", [e name], [e reason]);
        }
        
    };
    
    if ( [_privateContext hasChanges] == YES )
    {
        if ( wait == YES )
        {
            [_privateContext performBlockAndWait:savePrivate];
        }
        else
        {
            [_privateContext performBlock:savePrivate];
        }
    }
}

#pragma mark ---- singleton object methods ----

- (id) init
{
    self = [super init];
    if (self != nil) {
        [self initializeCoreDataStack];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            id localSelf;
            
            localSelf = [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone*)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

@end
