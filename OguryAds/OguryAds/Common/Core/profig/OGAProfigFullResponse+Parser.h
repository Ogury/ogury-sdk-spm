//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAProfigFullResponse.h"

@interface OGAProfigFullResponse (Parser)

+ (OGAProfigFullResponse *)parseProfigResponseWithData:(NSData *)response
                                           urlResponse:(NSURLResponse *)urlResponse;

@end
