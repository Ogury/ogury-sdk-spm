//
//  Copyright © 2024 Ogury. All rights reserved.
//

@protocol OGCConsentChangedDelegate <NSObject>
- (void)consentChanged;
- (void)dataPrivacyChanged:(NSString *)key boolean:(BOOL)value;
- (void)dataPrivacyChanged:(NSString *)key string:(NSString *)value;
- (void)dataPrivacyChanged:(NSString *)key integer:(NSInteger)value;
@end
