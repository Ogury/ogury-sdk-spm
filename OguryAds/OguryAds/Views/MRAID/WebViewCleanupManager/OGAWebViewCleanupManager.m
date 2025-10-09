//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGAWebViewCleanupManager.h"
#import "OGALog.h"

NSTimeInterval const OGAKeepAliveTime = 6;

@interface OGAWebViewCleanupManager ()

@property(nonatomic, assign) NSTimeInterval keepAliveTime;
@property(nonatomic, strong) NSMutableDictionary *keepAliveDict;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) NSDateFormatter *formater;

@end

@implementation OGAWebViewCleanupManager

#pragma mark - Initialization

+ (instancetype)shared {
    static OGAWebViewCleanupManager *instance;
    static dispatch_once_t token;

    dispatch_once(&token, ^{
        instance = [[OGAWebViewCleanupManager alloc] init];
    });

    return instance;
}

- (instancetype)init {
    return [self initWithKeepAliveTime:OGAKeepAliveTime log:[OGALog shared]];
}

- (instancetype)initWithKeepAliveTime:(NSTimeInterval)keepAliveTime log:(OGALog *)log {
    if (self = [super init]) {
        _formater = [[NSDateFormatter alloc] init];
        _formater.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";
        _keepAliveDict = [[NSMutableDictionary alloc] init];
        _log = log;
    }
    return self;
}

#pragma mark - Methods

- (void)cleanUpObject:(OGAMraidAdWebView *)object {
    if (!object) {
        return;
    }
    object.isWebviewClosed = YES;
    [object removeScriptMessageHandler];

    NSDate *toRemoveDate = [[NSDate date] dateByAddingTimeInterval:OGAKeepAliveTime];
    NSString *key = [self.formater stringFromDate:toRemoveDate];
    @synchronized(self) {
        self.keepAliveDict[key] = object;
        [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                             adConfiguration:nil
                                                     logType:OguryLogTypeInternal
                                                     message:[NSString stringWithFormat:@"⏰ Object %@ Added in Keep Alive", key]
                                                        tags:nil]];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)self.keepAliveTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        @synchronized(self) {
            [self.keepAliveDict removeObjectForKey:key];
            [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                                 adConfiguration:nil
                                                         logType:OguryLogTypeInternal
                                                         message:[NSString stringWithFormat:@"💥⏰💥 Object with key %@ removed from Keep alive", key]
                                                            tags:nil]];
        }
    });
}

@end
