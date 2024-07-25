//
//  Copyright © 12/11/2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface URLProtocolMock : NSURLProtocol

#pragma mark - Properties

@property (class, nonatomic, strong) NSDictionary<NSURL *, NSData *> *mockData;
@property (class, nonatomic, strong) NSDictionary<NSURL *, NSNumber *> *mockStatusCodeForURL;
@property (class, nonatomic, assign) BOOL shouldReturnError;

@end

NS_ASSUME_NONNULL_END
