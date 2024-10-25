//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryBannerAdSize.h"

@interface OguryBannerAdSize ()

@property CGSize size;

@end

@implementation OguryBannerAdSize 

#pragma mark - Initialization

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"-init is not a valid initializer for the class OguryBannerAdSize" userInfo:nil];
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

+ (OguryBannerAdSize *)small_banner_320x50 {
    return [[OguryBannerAdSize alloc] initWithSize:CGSizeMake(320, 50)];
}

+ (OguryBannerAdSize *)mrec_300x250 {
    return [[OguryBannerAdSize alloc] initWithSize:CGSizeMake(300, 250)];
}

@end
