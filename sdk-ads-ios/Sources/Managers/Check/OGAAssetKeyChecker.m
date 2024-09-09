//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGAAssetKeyChecker.h"
#import "OGAAssetKeyManager.h"
#import "OGALog.h"

@interface OGAAssetKeyChecker ()

@property(nonatomic, strong) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAAssetKeyChecker

#pragma mark - Initialization

- (instancetype)initFrom:(OguryInternalAdsErrorOrigin)origin {
    return [self initWithAssetKeyManager:[OGAAssetKeyManager shared] origin:origin log:[OGALog shared]];
}

- (instancetype)initWithAssetKeyManager:(OGAAssetKeyManager *)assetKeyManager
                                 origin:(OguryInternalAdsErrorOrigin)origin
                                    log:(OGALog *)log {
    if (self = [super init]) {
        _assetKeyManager = assetKeyManager;
        _log = log;
        _origin = origin;
    }
    return self;
}

#pragma mark - Methods

- (BOOL)checkForSequence:(OGAAdSequence *)sequence error:(OguryError **)error {
    BOOL isAssetKeyValid = [self.assetKeyManager checkAssetKeyIsValid:error origin:self.origin];

    if (!isAssetKeyValid) {
        [self.log logFormat:OguryLogLevelError format:@"Assetkey '%@' is not valid", self.assetKeyManager.assetKey];
    }

    return isAssetKeyValid;
}

@end
