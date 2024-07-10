//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OGCConstants: NSObject

extern NSString * const OguryErrorCoreDomain;

extern NSString * const OguryCoreErrorTypeNoInternetConnectionDesc;
extern NSString * const OguryCoreErrorTypeNoInternetConnectionRecoverySugg;

extern NSString * const OguryNetworkClientErrorDomain;
extern NSString * const OguryNetworkClientErrorLocalizedDescription;
extern NSString * const OguryNetworkClientErrorTypeUnknownLocalizedDescription;
extern NSString * const OguryNetworkClientErrorTypeUnknowLocalizedRecoverySuggestion;
extern NSString * const OguryNetworkClientErrorTypeInvalidURLLocalizedDescription;
extern NSString * const OguryNetworkClientErrorTypeInvalidURLLocaliedRecoverySuggestion;
extern NSString * const OguryNetworkClientErrorTypeEmptyResponseLocalizedDescription;
extern NSString * const OguryNetworkClientErrorTypeEmptyResponseLocalizedRecoverySuggestion;
extern NSString * const OguryNetworkClientErrorTypeClientErrorLocalizedDescription;
extern NSString * const OguryNetworkClientErrorTypeClientErrorLocalizedRecoverySuggestion;
extern NSString * const OguryNetworkClientErrorTypeServerErrorLocalizedDescription;
extern NSString * const OguryNetworkClientErrorTypeServerErrorLocalizedRecoverySuggestion;
extern NSString * const OguryNetworkClientErrorTypeNotYetImplementedLocalizedDescription;
extern NSString * const OguryNetworkClientErrorTypeNotYetImplementedLocalizedRecoverySuggestion;
extern NSString * const OGCOgury;
extern NSString * const OGCOguryCoreBundle;
extern NSInteger const OGCNetworkClientTimeoutIntervalForRequest;

@end

