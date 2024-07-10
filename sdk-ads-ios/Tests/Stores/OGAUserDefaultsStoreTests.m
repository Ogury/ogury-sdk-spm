//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAUserDefaultsStore.h"
#import "OGAAd.h"
#import "OGAAdConfiguration.h"

@interface OGAUserDefaultsStore ()

@property(nonatomic, strong) NSUserDefaults *userDefaults;

@end

@interface OGAUserDefaultsStoreTests : XCTestCase

@property(nonatomic, strong) OGAUserDefaultsStore *userDefaultsStore;

@end

@implementation OGAUserDefaultsStoreTests

#pragma mark - Constants

static NSString *const OGADefaultValue = @"Value";
static NSString *const OGADefaultKey = @"Key";

#pragma mark - Methods

- (void)setUp {
    self.userDefaultsStore = [OGAUserDefaultsStore shared];
}

- (void)testShouldSetObjectForKey {
    [self.userDefaultsStore setObject:OGADefaultValue forKey:OGADefaultKey];

    XCTAssertNotNil([self.userDefaultsStore.userDefaults valueForKey:OGADefaultKey]);
}

- (void)testShouldReturnDataForKey {
    [self.userDefaultsStore setObject:[OGADefaultValue dataUsingEncoding:NSUTF8StringEncoding] forKey:OGADefaultKey];

    NSData *storedData = [self.userDefaultsStore dataForKey:OGADefaultKey];

    NSString *decodedData = [[NSString alloc] initWithData:storedData encoding:NSUTF8StringEncoding];

    XCTAssertTrue([decodedData isEqualToString:OGADefaultValue]);
}

- (void)testShouldNotReturnDataForInvalidKey {
    NSData *storedData = [self.userDefaultsStore dataForKey:@"InvalidKey"];
    XCTAssertNil(storedData);
}

- (void)testShouldNotReturnStringForInvalidKey {
    NSString *storedData = [self.userDefaultsStore stringForKey:@"InvalidKey"];
    XCTAssertNil(storedData);
}

- (void)testShouldReturnStringForKey {
    [self.userDefaultsStore setObject:OGADefaultValue forKey:OGADefaultKey];

    NSString *storedString = [self.userDefaultsStore stringForKey:OGADefaultKey];

    XCTAssertTrue([storedString isEqualToString:OGADefaultValue]);
}

@end
