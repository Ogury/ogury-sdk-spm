//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#ifndef OGMEventServerMonitorable_h
#define OGMEventServerMonitorable_h

typedef NS_ENUM(NSInteger, OGMDispatchType) {
    OGMDispatchTypeImmediate,
    OGMDispatchTypeDeferred,
};

@protocol OGMEventServerMonitorable <NSObject>

@property(nonatomic, assign) OGMDispatchType dispatchType;

@end

#endif /* OGMEventServerMonitorable_h */
