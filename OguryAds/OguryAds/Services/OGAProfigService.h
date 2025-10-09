//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAProfigFullResponse.h"

typedef void (^ProfigCompletionBlock)(OGAProfigFullResponse *, NSError *);

@interface OGAProfigService : NSObject

- (void)loadWithCompletion:(ProfigCompletionBlock)completion;

- (void)reset;

@end
