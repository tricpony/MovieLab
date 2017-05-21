//
//  RKNetworkClient.m
//  MovieLab
//
//  Created by aarthur on 5/10/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

#import "RKNetworkClient.h"
#import "CoreDataStack.h"

#pragma mark - Core Field Keys
NSString * const API_CoreFieldBackdropPathKey = @"backdrop_path";
NSString * const API_CoreFieldMovieIDKey = @"id";
NSString * const API_CoreFieldMovieGenreIDKey = @"id";
NSString * const API_CoreFieldOverViewKey = @"overview";
NSString * const API_CoreFieldPosterPathKey = @"poster_path";
NSString * const API_CoreFieldReleaseDateKey = @"release_date";
NSString * const API_CoreFieldTitleKey = @"title";
NSString * const API_CoreFieldGenreNameKey = @"name";
NSString * const API_CoreFieldGenreKey = @"genre_ids";
NSString * const API_MovieSearchEP = @"search/movie";
NSString * const API_MovieSGenreEP = @"genre/movie/list";

#pragma mark - Notification UserInfo Keys

NSString * const VN_BytesWrittenSinceLastCall = @"VN_BytesWrittenSinceLastCall";
NSString * const VN_TotalBytesWritten = @"VN_TotalBytesWritten";
NSString * const VN_TotalBytesExpected = @"VN_TotalBytesExpected";

#pragma mark - Notification Names

NSString * const VN_IncrementActivityCountNotification = @"VN_IncrementActivityCountNotification";

@interface RKNetworkClient()
@property (assign, nonatomic) BOOL didConfigDescriptors;
@property (nonatomic, strong) AFRKHTTPClient *client;
@property (strong, nonatomic) VNRestKitOperationProgressBlock progressBlock;

@end

@implementation RKNetworkClient

+ (RKEntityMapping*)movieRequestMapping
{
    RKManagedObjectStore * mos = [[RKObjectManager sharedManager] managedObjectStore];
    RKEntityMapping *requestMapping = [RKEntityMapping mappingForEntityForName:@"Movie" inManagedObjectStore:mos];
    RKEntityMapping *genreMapping = [RKEntityMapping mappingForEntityForName:@"Genre" inManagedObjectStore:mos];
    
    [requestMapping addAttributeMappingsFromDictionary:[self getRKAttributeMovieMapping]];
    [requestMapping setIdentificationAttributes:[self getRKIdentificationAttributes]];
    
    //http://stackoverflow.com/questions/17187686/restkit-mapping-json-array-of-strings
    [genreMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"genreID"]];
    [genreMapping setIdentificationAttributes:@[@"genreID"]];
    
    //assign relationship mappings
    [requestMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CoreFieldGenreKey
                                                                                   toKeyPath:@"genres"
                                                                                 withMapping:genreMapping]];
    
    return requestMapping;
}

+ (RKEntityMapping*)movieGenreRequestMapping
{
    RKManagedObjectStore * mos = [[RKObjectManager sharedManager] managedObjectStore];
    RKEntityMapping *requestMapping = [RKEntityMapping mappingForEntityForName:@"Genre" inManagedObjectStore:mos];
    
    [requestMapping addAttributeMappingsFromDictionary:[self getRKAttributeMovieGenreMapping]];
    [requestMapping setIdentificationAttributes:@[@"genreID"]];
    
    return requestMapping;
}

+ (NSString*)rkKeyPath
{
    return @"results";
}

+ (NSDictionary*)getRKAttributeMovieMapping
{
    return @{API_CoreFieldMovieIDKey : @"movieID",
             API_CoreFieldBackdropPathKey : @"backdropPath",
             API_CoreFieldOverViewKey : @"overview",
             API_CoreFieldPosterPathKey : @"posterPath",
             API_CoreFieldReleaseDateKey : @"releaseDate",
             API_CoreFieldTitleKey : @"title"
             };
}

+ (NSDictionary*)getRKAttributeMovieGenreMapping
{
    return @{API_CoreFieldMovieGenreIDKey : @"genreID",
             API_CoreFieldGenreNameKey : @"name"
             };
}

+ (NSArray*)getRKIdentificationAttributes
{
    return @[@"movieID"];
}

+ (RKResponseDescriptor*)getSyncDownMovieRKDescriptor
{
    RKResponseDescriptor *descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self movieRequestMapping]
                                                                                    method:RKRequestMethodGET
                                                                               pathPattern:API_MovieSearchEP
                                                                                   keyPath:[self rkKeyPath]
                                                                               statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return descriptor;
}

+ (RKResponseDescriptor*)getSyncDownMovieGenreRKDescriptor
{
    RKResponseDescriptor *descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self movieGenreRequestMapping]
                                                                                    method:RKRequestMethodGET
                                                                               pathPattern:API_MovieSGenreEP
                                                                                   keyPath:@"genres"
                                                                               statusCodes:[NSIndexSet indexSetWithIndex:200]];
    return descriptor;
}

- (void)configureMovieRequestClient
{
    if (!self.client) {
        self.client = [[AFRKHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:API_BaseMovieURL]];
        [[RKObjectManager sharedManager] setHTTPClient:self.client];
        [[RKObjectManager sharedManager] setRequestSerializationMIMEType:RKMIMETypeJSON];
        [[RKObjectManager sharedManager] setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    }
}

- (void)configureGenreRequestClient
{
    if (!self.client) {
        self.client = [[AFRKHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:API_BaseMovieURL]];
        [[RKObjectManager sharedManager] setHTTPClient:self.client];
        [[RKObjectManager sharedManager] setRequestSerializationMIMEType:RKMIMETypeJSON];
        [[RKObjectManager sharedManager] setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    }
}

- (void)addMovieDescriptors
{
    if (!self.didConfigDescriptors) {
        [[RKObjectManager sharedManager] addResponseDescriptorsFromArray:@[[[self class] getSyncDownMovieRKDescriptor]]];
        self.didConfigDescriptors = YES;
    }
}

- (void)addMovieGenreDescriptors
{
    if (!self.didConfigDescriptors) {
        [[RKObjectManager sharedManager] addResponseDescriptorsFromArray:@[[[self class] getSyncDownMovieGenreRKDescriptor]]];
        self.didConfigDescriptors = YES;
    }
}

#pragma mark ---- KVO for progress ----

-  (void)observeValueForKeyPath:(NSString*)kp ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    RKObjectRequestOperation *syncDownOperation = nil;
    NSOperationQueue *queue = (id)object;
    
    //clean up now
    [object removeObserver:self forKeyPath:@"operations"];
    
    syncDownOperation = [[queue operations] firstObject];
    [syncDownOperation.HTTPRequestOperation setDownloadProgressBlock:self.progressBlock];
}

- (void)configureOperationQueueForObserving
{
    NSOperationQueue *queue = nil;
    
    queue = [[RKObjectManager sharedManager] operationQueue];
    [queue addObserver:self forKeyPath:@"operations" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)performNetworkMovieFetchMatchingParameters:(NSDictionary*)params
                                      successBlock:(SuccessRKServiceCompletion)successBlock
                                      failureBlock:(FailureRKServiceCompletion)failureBlock
{
    NSMutableDictionary *parameters;
    
    [self configureMovieRequestClient];
    [self addMovieDescriptors];
    [self configureOperationQueueForObserving];
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    //this is the progress call back block
    //
    self.progressBlock = ^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSDictionary *userInfo;
        
        userInfo = @{
                     VN_BytesWrittenSinceLastCall:@(bytesWritten),
                     VN_TotalBytesWritten:@(totalBytesWritten),
                     VN_TotalBytesExpected:@(totalBytesExpectedToWrite)
                     };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VN_IncrementActivityCountNotification object:nil userInfo:userInfo];
    };
    //
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    parameters[@"api_key"] = @"84da8aabe6e251daaaacea2b0db89dfb";
    
    [[RKObjectManager sharedManager] getObjectsAtPath:API_MovieSearchEP
                                           parameters:parameters
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  successBlock(mappingResult.array);
                                                  
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  
                                                  failureBlock(error);
                                                  
                                              }];
}

- (void)performNetworkMovieGenreFetchWithsuccessBlock:(SuccessRKServiceCompletion)successBlock
                                                  failureBlock:(FailureRKServiceCompletion)failureBlock
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [self configureGenreRequestClient];
    [self addMovieGenreDescriptors];

    parameters[@"api_key"] = @"84da8aabe6e251daaaacea2b0db89dfb";
    
    [[RKObjectManager sharedManager] getObjectsAtPath:API_MovieSGenreEP
                                           parameters:parameters
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  if (successBlock) {
                                                      successBlock(mappingResult.array);
                                                  }
                                                  
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  if (failureBlock) {
                                                      failureBlock(error);
                                                  }
                                                  NSLog(@"Error url: %@",operation.HTTPRequestOperation.response.URL);
                                              }];
    self.client = nil;
}

@end
