//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OGAEnvironmentManager : NSObject

@property(nonatomic, strong, readonly) NSURL *adSyncURL;
@property(nonatomic, strong, readonly) NSURL *launchURL;
@property(nonatomic, strong, readonly) NSURL *preCacheURL;
@property(nonatomic, strong, readonly) NSURL *profigURL;
@property(nonatomic, strong, readonly) NSURL *trackURL;
@property(nonatomic, strong, readonly) NSURL *adHistoryURL;
@property(nonatomic, strong, readonly) NSURL *monitoringURL;

+ (instancetype)shared;

- (void)updateWith:(NSString *)environment;

@end
