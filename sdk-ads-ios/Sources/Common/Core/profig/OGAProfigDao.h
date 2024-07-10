//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAProfigDao.h"
#import "OGAProfigFullResponse.h"

// IdLess profig Keys
#define FULL_PROFIG_RESPONSE_JSON_IDLESS @"fullProfigResponseIdLessJsonKey"
#define PROFIG_LAST_PROFIG_SYNC_IDLESS @"lastProfigSyncKeyIdLess"
#define LAST_INSTANCE_TOKEN_PROFIG_PARAM_IDLESS @"LastIntanceTokenProfigParamIdLess"

// Old userdefault profig Keys
#define PROFIG_FULL_PROFIG_RESPONSE_JSON @"fullProfigResponseJsonKey"
#define PROFIG_LAST_PROFIG_SYNC @"lastProfigSyncKey"
#define LAST_INSTANCE_TOKEN_PROFIG_PARAM @"LastIntanceTokenProfigParam"

NS_ASSUME_NONNULL_BEGIN

@interface OGAProfigDao : NSObject

@property(nonatomic, strong, nullable) NSDate *lastProfigSyncDate;
@property(nonatomic, strong, nullable) OGAProfigFullResponse *profigFullResponse;
@property(nonatomic, strong) NSMutableDictionary *profigParams;
@property(nonatomic, copy, nullable) NSString *profigInstanceToken;

+ (instancetype)shared;

- (instancetype)init;

- (OGAProfigDao *)sync;

- (void)updateWithFullProfig:(OGAProfigFullResponse *)profig;

- (void)reset;

- (BOOL)shouldMigrateToIdless;

@end

NS_ASSUME_NONNULL_END
