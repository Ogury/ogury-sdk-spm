//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "OGAJSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAMraidCommand : OGAJSONModel

#pragma mark - Properties

@property(nonatomic, copy) NSString *method;
@property(nonatomic, strong) NSMutableDictionary *args;
@property(nonatomic, copy) NSString *callbackId;

#pragma mark - Methods

+ (instancetype)MraidCloseCommandWithNextAdFalse;

+ (instancetype)MraidForceCloseCommandWithNextAdFalse;

+ (instancetype)MraidUnloadCommandWithNextAdFalse;

+ (instancetype)mraidTimeoutUnloadCommand;

@end

NS_ASSUME_NONNULL_END
