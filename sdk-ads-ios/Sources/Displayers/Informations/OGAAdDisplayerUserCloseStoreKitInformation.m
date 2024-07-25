//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdDisplayerUserCloseStoreKitInformation.h"
#import "OGALog.h"

@interface OGAAdDisplayerUserCloseStoreKitInformation ()

@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAAdDisplayerUserCloseStoreKitInformation

#pragma mark - Initialization

- (instancetype)initWithErrorCode:(NSNumber *)errorCode log:(OGALog *)log {
    if (self = [super init]) {
        _errorCode = errorCode;
        _log = log;
    }
    return self;
}

- (instancetype)initWithErrorCode:(NSNumber *)errorCode {
    return [self initWithErrorCode:errorCode log:[OGALog shared]];
}

#pragma mark - Methods

- (NSString *)toJavascriptCommand {
    if (!self.errorCode) {
        return [NSString stringWithFormat:@"ogySdkMraidGateway.ogyCloseStoreKit()"];
    } else {
        return [NSString stringWithFormat:@"ogySdkMraidGateway.ogyCloseStoreKit({error_code:%@})", self.errorCode];
    }
}

@end
