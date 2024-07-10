//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OGCNSProcessInfoMock.h"

@implementation OGCNSProcessInfoMock

- (id)initWithMajorVersion:(NSInteger)majorVersion {
   if (self = [super init]) {
       NSOperatingSystemVersion version;
       version.majorVersion = majorVersion;
       version.minorVersion = 0;
       version.patchVersion = 0;
       _mockedOperatingSystemVersion = version;
   }
   return self;
}

- (NSOperatingSystemVersion)operatingSystemVersion {
   return self.mockedOperatingSystemVersion;
}

- (void)updateMajorVersion:(NSInteger)majorVersion {
   NSOperatingSystemVersion version;
   version.majorVersion = majorVersion;
   version.minorVersion = 0;
   version.patchVersion = 0;
   self.mockedOperatingSystemVersion = version;
}

@end
