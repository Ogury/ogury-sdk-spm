//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryAdsBannerSize.h"

@interface OguryAdsBannerSize ()

@property CGSize size;

@end

@implementation OguryAdsBannerSize

#pragma mark - Initialization

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"-init is not a valid initializer for the class OguryAdsBannerSize" userInfo:nil];
    return nil;
}

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super init]) {
        _size = size;
    }

    return self;
}

#pragma mark - Methods

- (CGSize)getSize {
    return self.size;
}

+ (OguryAdsBannerSize *)small_banner_320x50 {
    return [[OguryAdsBannerSize alloc] initWithSize:CGSizeMake(320, 50)];
}

+ (OguryAdsBannerSize *)mrec_300x250 {
    return [[OguryAdsBannerSize alloc] initWithSize:CGSizeMake(300, 250)];
}

@end
