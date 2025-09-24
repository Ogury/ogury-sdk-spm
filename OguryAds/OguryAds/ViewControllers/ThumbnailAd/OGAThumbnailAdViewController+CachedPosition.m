//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAThumbnailAdViewController+CachedPosition.h"
#import "OGAThumbnailAdViewController+Position.h"
#import "OguryRectCorner.h"
#import "OguryOffset.h"
#import "OGAThumbnailAdCachedPositionObject.h"
#import "OGAAd.h"

NSString *const OGAThumbnailCachedPositionKey = @"OGAThumbnailCachedPositionKey";

@interface OGAThumbnailAdViewController ()

@property(nonatomic, strong) NSUserDefaults *userDefaults;
@property(nonatomic, assign) OguryOffset offsetRatio;
@property(nonatomic, assign) OguryRectCorner rectCorner;
@property(nonatomic, strong) NSString *customThumbnailCachedPositionKey;
@property(nonatomic, strong) OGAThumbnailAdCachedPositionObject *cachedThumbnailAdPosition;

@end

@implementation OGAThumbnailAdViewController (CachedPosition)

#pragma mark - Methods

- (void)cacheThumbnailAdPosition {
    [self cacheThumbnailAdPositionWithOffsetRatio:self.offsetRatio rectCorner:self.rectCorner];
}

- (BOOL)updateToCachedThumbnailAdPositionWithAdUnitId:(NSString *)adUnitId {
    if ([self hasCachedPositionForThumbnailAdWithAdUnitId:adUnitId]) {
        [self applyCachedThumbnailAdPosition];
        return YES;
    }
    return NO;
}

- (BOOL)hasCachedPositionForThumbnailAdWithAdUnitId:(NSString *)adUnitId {
    [self defineCustomThumbnailAdCachedPositionKeyWithAdUnitId:adUnitId];
    [self fetchCachedThumbnailAdPosition];
    return self.cachedThumbnailAdPosition != nil;
}

- (void)applyCachedThumbnailAdPosition {
    [self initThumbnailSize];
    [self applyCachedThumbnailAdPositionToCurrentPosition];
    [self applyOffsetToPosition];
    [self checkThumbnailCorrectPosition];
    [self updateOffsetRatio];
}

- (void)applyCachedThumbnailAdPositionToCurrentPosition {
    self.offsetRatio = self.cachedThumbnailAdPosition.offsetRatio;
    self.rectCorner = self.cachedThumbnailAdPosition.rectCorner;
}

- (void)cacheThumbnailAdPositionWithOffsetRatio:(OguryOffset)offsetRatio rectCorner:(OguryRectCorner)rectCorner {
    self.cachedThumbnailAdPosition = [[OGAThumbnailAdCachedPositionObject alloc] initWithOguryOffsetRatio:offsetRatio rectCorner:rectCorner];
    [self.userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.cachedThumbnailAdPosition] forKey:self.customThumbnailCachedPositionKey];
}

- (void)defineCustomThumbnailAdCachedPositionKeyWithAdUnitId:(NSString *)adUnitId {
    self.customThumbnailCachedPositionKey = [NSString stringWithFormat:@"%@_%@", OGAThumbnailCachedPositionKey, adUnitId];
}

- (void)fetchCachedThumbnailAdPosition {
    NSData *keyData = [self.userDefaults objectForKey:self.customThumbnailCachedPositionKey];
    if (keyData != nil) {
        self.cachedThumbnailAdPosition = [NSKeyedUnarchiver unarchiveObjectWithData:keyData];
    }
}

@end
