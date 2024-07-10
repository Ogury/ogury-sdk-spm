//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OGCConstants.h"

@implementation OGCConstants

NSString * const OguryErrorCoreDomain = @"OguryErrorCoreDomain";

NSString * const OguryCoreErrorTypeNoInternetConnectionDesc = @"The device has no Internet connection.";
NSString * const OguryCoreErrorTypeNoInternetConnectionRecoverySugg = @"Try again when the device is connected to the Internet again.";

NSString * const OguryNetworkClientErrorDomain = @"co.ogury.core.network";
NSString * const OguryNetworkClientErrorLocalizedDescription = @"An error occurred.";
NSString * const OguryNetworkClientErrorTypeUnknownLocalizedDescription = @"An unknown error occurred.";
NSString * const OguryNetworkClientErrorTypeUnknowLocalizedRecoverySuggestion = @"Please check your implementation.";
NSString * const OguryNetworkClientErrorTypeInvalidURLLocalizedDescription = @"The specified URL is invalid.";
NSString * const OguryNetworkClientErrorTypeInvalidURLLocaliedRecoverySuggestion = @"Please check that the specified URL is not empty and can be resolved.";
NSString * const OguryNetworkClientErrorTypeEmptyResponseLocalizedDescription = @"An empty response was returned.";
NSString * const OguryNetworkClientErrorTypeEmptyResponseLocalizedRecoverySuggestion = @"Please check with the support team.";
NSString * const OguryNetworkClientErrorTypeClientErrorLocalizedDescription = @"A client error occurred.";
NSString * const OguryNetworkClientErrorTypeClientErrorLocalizedRecoverySuggestion = @"Please check the network client implementation.";
NSString * const OguryNetworkClientErrorTypeServerErrorLocalizedDescription = @"A server error occurred.";
NSString * const OguryNetworkClientErrorTypeServerErrorLocalizedRecoverySuggestion = @"Please check with the support team.";
NSString * const OguryNetworkClientErrorTypeNotYetImplementedLocalizedDescription = @"Not yet implemented.";
NSString * const OguryNetworkClientErrorTypeNotYetImplementedLocalizedRecoverySuggestion = @"Please contact the support team.";
NSString * const OGCOgury = @"Ogury";
NSString * const OGCOguryCoreBundle = SDK_BUNDLE_IDENTIFER;
NSInteger const OGCNetworkClientTimeoutIntervalForRequest = 30;

@end
