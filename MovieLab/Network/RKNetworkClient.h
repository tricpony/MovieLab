//
//  RKNetworkClient.h
//  MovieLab
//
//  Created by aarthur on 5/10/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#import <RestKit/RestKit.h>
#pragma clang pop

#pragma mark - Core Field Keys

FOUNDATION_EXPORT NSString * const API_CoreFieldBackdropPathKey;
FOUNDATION_EXPORT NSString * const API_CoreFieldMovieIDKey;
FOUNDATION_EXPORT NSString * const API_CoreFieldOverViewKey;
FOUNDATION_EXPORT NSString * const API_CoreFieldPosterPathKey;
FOUNDATION_EXPORT NSString * const API_CoreFieldReleaseDateKey;
FOUNDATION_EXPORT NSString * const API_CoreFieldTitleKey;
FOUNDATION_EXPORT NSString * const API_CoreFieldGenreKey;

#pragma mark - Notification UserInfo Keys

FOUNDATION_EXPORT NSString * const VN_BytesWrittenSinceLastCall;
FOUNDATION_EXPORT NSString * const VN_TotalBytesWritten;
FOUNDATION_EXPORT NSString * const VN_TotalBytesExpected;

#pragma mark - Notification Names

FOUNDATION_EXPORT NSString * const VN_IncrementActivityCountNotification;

typedef void (^SuccessRKServiceCompletion)(NSArray *results);
typedef void (^FailureRKServiceCompletion)(NSError *error);
typedef void (^VNRestKitOperationProgressBlock)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);

@interface RKNetworkClient : NSObject

- (void)performNetworkMovieFetchMatchingParameters:(NSDictionary*)params
                                      successBlock:(SuccessRKServiceCompletion)successBlock
                                      failureBlock:(FailureRKServiceCompletion)failureBlock;

- (void)performNetworkCastFetchMatchingMovieID:(NSNumber*)movieID
                                  successBlock:(SuccessRKServiceCompletion)successBlock
                                  failureBlock:(FailureRKServiceCompletion)failureBlock;

- (void)performNetworkMovieGenreFetchWithsuccessBlock:(SuccessRKServiceCompletion)successBlock
                                                  failureBlock:(FailureRKServiceCompletion)failureBlock;

@end
