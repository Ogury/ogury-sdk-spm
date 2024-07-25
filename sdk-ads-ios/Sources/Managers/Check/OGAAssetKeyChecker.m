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

- (instancetype)init {
    return [self initWithAssetKeyManager:[OGAAssetKeyManager shared] log:[OGALog shared]];
}

- (instancetype)initWithAssetKeyManager:(OGAAssetKeyManager *)assetKeyManager log:(OGALog *)log {
    if (self = [super init]) {
        _assetKeyManager = assetKeyManager;
        _log = log;
    }
    return self;
}

#pragma mark - Methods

- (BOOL)checkForSequence:(OGAAdSequence *)sequence error:(OguryError **)error {
    BOOL isAssetKeyValid = [self.assetKeyManager checkAssetKeyIsValid:error];

    if (!isAssetKeyValid) {
        [self.log logFormat:OguryLogLevelError format:@"Assetkey '%@' is not valid", self.assetKeyManager.assetKey];
    }

    return isAssetKeyValid;
}

@end
