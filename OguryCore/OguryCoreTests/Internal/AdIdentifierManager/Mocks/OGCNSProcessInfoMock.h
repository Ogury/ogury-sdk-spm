//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGCNSProcessInfoMock : NSProcessInfo

@property (nonatomic) NSOperatingSystemVersion mockedOperatingSystemVersion;

- (id)initWithMajorVersion:(NSInteger)majorVersion;
- (void)updateMajorVersion:(NSInteger)majorVersion;

@end

NS_ASSUME_NONNULL_END
