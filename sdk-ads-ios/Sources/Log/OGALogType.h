//
//  OGALogType.h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 11/09/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//
#import <OguryCore/OguryLogMessage.h>

#ifndef OGALogType_h
#define OGALogType_h

typedef NS_ENUM(NSInteger, OGALogType) {
    OGALogTypeInternal = 0,
    OGALogTypeDelegates,
    OGALogTypeMonitoring,
    OGALogTypeRequests,
    OGALogTypeMraid,
    OGALogTypeTestApp
};

@protocol OGALogMessage <OguryLogMessage>
@property(nonatomic) OGALogType *_Nullable logType;
@property(nonatomic, retain) NSDate *_Nonnull date;
@property(nonatomic, retain) NSArray<NSString *> *_Nullable tags;
- (instancetype _Nonnull)initWithLevel:(OguryLogLevel)level
                                  type:(OGALogType)logType
                               message:(NSString *_Nonnull)message
                                  tags:(NSArray<NSString *> *_Nullable)tags;
@end

@protocol OguryAdsLogger <OguryLogger>
- (void)logMessage:(id<OGALogMessage> _Nonnull)message;
@end

#endif /* OGALogType_h */
