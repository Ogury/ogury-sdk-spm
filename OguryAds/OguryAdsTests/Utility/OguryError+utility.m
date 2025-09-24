//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "OguryError+utility.h"

@implementation OguryError (utility)
+ (instancetype)makeError {
    return [OguryError errorWithDomain:@"Ogury" code:666 userInfo:nil];
}
@end
