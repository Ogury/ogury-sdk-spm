//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGWModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGWModulesManager : NSObject

#pragma mark - Properties

@property (nonatomic, strong, readonly) NSArray *modules;

@property (nonatomic, strong, readonly, nullable) OGWModule *coreModule;

@property (nonatomic, strong, readonly, nullable) OGWModule *adsModule;

#pragma mark - Initialization

+ (OGWModulesManager *)shared;

@end

NS_ASSUME_NONNULL_END
