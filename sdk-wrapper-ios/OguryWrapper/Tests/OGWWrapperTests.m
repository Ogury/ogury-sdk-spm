//
//  Copyright © 2015 - 25/07/2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGWModules.h"
#import "OGWMonitoringInfoManager.h"
#import "OGWSetLogLevelNotificationManager.h"
#import "OGWWrapper.h"

@interface OGWWrapper (Testing)

- (instancetype)initWithModules:(OGWModules *)modules
          monitoringInfoManager:(OGWMonitoringInfoManager *)monitoringInfoManager
         logNotificationManager:(OGWSetLogLevelNotificationManager *)logNotificationManager
                    userDefault:(NSUserDefaults *)userDefault;

@end

@interface OGWWrapperTests : XCTestCase

@end

@implementation OGWWrapperTests

- (void)testLogNotificationRegister {
   id modules = OCMClassMock([OGWModules class]);
   id monitoringInfoManager = OCMClassMock([OGWMonitoringInfoManager class]);
   id receiver = OCMClassMock([OGWSetLogLevelNotificationManager class]);
   id userDefault = OCMClassMock([NSUserDefaults class]);

   id wrapperInstant = [[OGWWrapper alloc] initWithModules:modules
                                     monitoringInfoManager:monitoringInfoManager
                                    logNotificationManager:receiver
                                               userDefault:userDefault];

   // no action need since the register is triggered in OGWWrapper's init
   XCTAssertNotNil(wrapperInstant);
   OCMVerify([receiver registerToNotification]);
}

@end
