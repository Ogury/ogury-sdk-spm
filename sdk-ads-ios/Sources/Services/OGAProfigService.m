//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAProfigService.h"
#import "OGAProfigRequestBuilder.h"
#import "OGAConfigurationUtils+Profig.h"
#import "OGALog.h"
#import "OGAProfigFullResponse+Parser.h"
#import <OguryCore/OguryNetworkClient.h>
#import <OguryCore/OguryNetworkClientError.h>
#import "OGAEXTScope.h"
#import "OGAAdQualityController.h"

@interface OGAProfigService ()

@property(atomic, assign) BOOL profigLoadTaskInProgress;
@property(atomic, strong) OGALog *log;
@property(atomic, strong) OGAAdQualityController *adQualityController;

@end

@implementation OGAProfigService

- (instancetype)init {
    return [self init:[OGALog shared] adQualityController:[OGAAdQualityController shared]];
}

- (instancetype)init:(OGALog *)log adQualityController:(OGAAdQualityController*)adQualityController {
    if (self = [super init]) {
        _profigLoadTaskInProgress = NO;
        _log = log;
        _adQualityController = adQualityController;
    }
    return self;
}

#pragma mark - Public methods

- (void)loadWithCompletion:(ProfigCompletionBlock)completion {
    NSURLRequest *profigRequest = [OGAProfigRequestBuilder build];
    [self fetchProfigWithRequest:profigRequest completion:completion];
}

#pragma mark - Private methods

- (void)fetchProfigWithRequest:(NSURLRequest *)profigRequest completion:(ProfigCompletionBlock)completion {
    if (![OGAConfigurationUtils isConnectedToInternet]) {
        completion(nil, [OGAConfigurationUtils errorForOGAProfigError:OGAProfigExternalErrorNoInternet]);
        return;
    }
    if (self.profigLoadTaskInProgress) {
        completion(nil, [OGAConfigurationUtils errorForOGAProfigError:OGAProfigExternalErrorAlreadyLoading]);
        return;
    }
    self.profigLoadTaskInProgress = YES;
    @weakify(self)
    [[OguryNetworkClient shared] performRequest:profigRequest
               completionHandlerWithUrlResponse:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        @strongify(self)
        // we still try to parse the profig since we can have business errors in a 400 response
        OGAProfigFullResponse *profigResponse = [OGAProfigFullResponse parseProfigResponseWithData:data urlResponse:response];
        [self.adQualityController setUpFrom:profigResponse.adQualityConfiguration];
        if (error) {
            NSError *completionError = (profigResponse.errorType || profigResponse.errorMessage)
            ? [OGAConfigurationUtils errorForServerProfigError:profigResponse]
            : [OGAConfigurationUtils errorForOGAProfigError:OGAProfigExternalErrorSetupFailed];
            completion(profigResponse, completionError);
        } else {
            [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                 adConfiguration:nil
                                                         logType:OguryLogTypeInternal
                                                         message:@"[Setup] profig raw response"
                                                            tags:@[
                [OguryLogTag tagWithKey:@"response"
                                  value:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]
            ]]];
            
            if (response) {
                if (profigResponse.errorType || profigResponse.errorMessage) {
                    completion(profigResponse, [OGAConfigurationUtils errorForServerProfigError:profigResponse]);
                } else {
                    completion(profigResponse, nil);
                }
            } else {
                completion(profigResponse, [OGAConfigurationUtils errorForOGAProfigError:OGAProfigExternalErrorSetupFailed]);
            }
        }
        self.profigLoadTaskInProgress = NO;
                   }];
}

- (void)reset {
    self.profigLoadTaskInProgress = NO;
}

@end
