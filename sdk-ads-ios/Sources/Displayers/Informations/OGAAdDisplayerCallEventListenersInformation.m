//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAAdDisplayerCallEventListenersInformation.h"
#import "OGALog.h"

@interface OGAAdDisplayerCallEventListenersInformation ()

@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAAdDisplayerCallEventListenersInformation

#pragma mark - Initialization

- (instancetype)initWithEvent:(NSString *)trigger parameters:(NSDictionary *)paramters log:(OGALog *)log {
    if (self = [super init]) {
        _trigger = trigger;
        _parameters = paramters;
        _log = log;
    }
    return self;
}

- (instancetype)initWithEvent:(NSString *)trigger parameters:(NSDictionary *)paramters {
    return [self initWithEvent:trigger parameters:paramters log:[OGALog shared]];
}

#pragma mark - Methods

- (NSString *)toJavascriptCommand {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.parameters options:NSJSONWritingFragmentsAllowed error:&error];
    if (!error && jsonData != nil) {
        NSString *jsonParameters = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return [NSString stringWithFormat:@"ogySdkMraidGateway.callEventListeners(\"%@\", %@)", self.trigger, jsonParameters];
    } else if (error != nil) {
        [self.log logErrorFormat:error format:@"toJavascriptCommand Unable to parse json object: %@", error.description];
        return @"";
    }
    // should never happen
    return @"";
}

@end
