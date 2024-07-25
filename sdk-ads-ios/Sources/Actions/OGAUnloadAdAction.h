//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdAction.h"
#import "OGANextAd.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAUnloadAdAction : NSObject <OGAAdAction>

#pragma mark - Constants

extern NSString *const OGAUnloadAdActionName;

#pragma mark - Properties

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong, nullable) OGANextAd *nextAd;

#pragma mark - Initialization

- (instancetype)initWithNextAd:(OGANextAd *_Nullable)nextAd;

@end

NS_ASSUME_NONNULL_END
