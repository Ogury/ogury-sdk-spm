//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGWModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGWModules : NSObject

#pragma mark - Properties

@property (nonatomic, strong, readonly) NSArray *modules;

@property (nonatomic, strong, readonly, nullable) OGWModule *coreModule;

@property (nonatomic, strong, readonly, nullable) OGWModule *adsModule;

@property (nonatomic, strong, readonly, nullable) OGWModule *choiceManagerModule;

#pragma mark - Initialization

+ (OGWModules *)shared;

@end

NS_ASSUME_NONNULL_END
