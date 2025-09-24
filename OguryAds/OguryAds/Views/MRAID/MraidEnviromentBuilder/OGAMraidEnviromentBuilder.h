//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OGAAdUnit;

@interface OGAMraidEnviromentBuilder : NSObject

#pragma mark - Methods

+ (NSString *)generateMraidEnviroment:(OGAAdUnit *)adUnit;

@end
