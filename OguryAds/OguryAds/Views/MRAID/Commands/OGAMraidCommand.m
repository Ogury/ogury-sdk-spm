//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "OGAMraidCommand.h"

@implementation OGAMraidCommand

#pragma mark - Methods

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return true;
}

+ (instancetype)MraidCloseCommandWithNextAdFalse {
    return [[OGAMraidCommand alloc] initWithString:@"{\"method\":\"close\",\"args\":{\"showNextAd\":false}}" error:nil];
}

+ (instancetype)MraidForceCloseCommandWithNextAdFalse {
    return [[OGAMraidCommand alloc] initWithString:@"{\"method\":\"ogyForceClose\",\"args\":{\"showNextAd\":false}}" error:nil];
}

+ (instancetype)MraidUnloadCommandWithNextAdFalse {
    return [[OGAMraidCommand alloc] initWithString:@"{\"method\":\"unload\",\"args\":{\"showNextAd\":false}}" error:nil];
}

+ (instancetype)mraidTimeoutUnloadCommand {
    return [[OGAMraidCommand alloc] initWithString:@"{\"method\":\"unload\",\"args\":{\"showNextAd\":false,\"timeout\":true}}" error:nil];
}

@end
