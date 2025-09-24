//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "NSString+OGABase64.h"

@interface NSString_OGABase64Tests : XCTestCase

@end

@implementation NSString_OGABase64Tests

- (void)testOgaEncodeStringTo64Normal {
    NSString *normalStringContent = @"azertyuiop1234567890";
    NSString *expectedbase64NormalStringContent = @"YXplcnR5dWlvcDEyMzQ1Njc4OTA=";
    XCTAssertEqualObjects([normalStringContent ogaEncodeStringTo64], expectedbase64NormalStringContent);
}

- (void)testOgaEncodeStringTo64Json {
    NSString *jsonStringContent = @"e1wiYXBwXCIgOiB7XCJhc3NldF9rZXlcIiA6IFwiT0dZLVhYWFwiLFwiaW5zdGFuY2VfdG9rZW5cIiA6IFwiWFhYWC1YWFhYLVhYWFgtWFhYWFwifSxcInNka1wiIDoge1widmVyc2lvblwiIDogXCI1LjUuNVwifSxcImRldmljZVwiIDp7XCJvcmllbnRhdGlvblwiIDogXCJwb3J0cmFpdFwiLFwidGltZV96b25lXCIgOiBcIiswMDowMFwifX0=";
    NSString *expectedbase64jsonStringContent = @"ZTF3aVlYQndYQ0lnT2lCN1hDSmhjM05sZEY5clpYbGNJaUE2SUZ3aVQwZFpMVmhZV0Z3aUxGd2lhVzV6ZEdGdVkyVmZkRzlyWlc1Y0lpQTZJRndpV0ZoWVdDMVlXRmhZTFZoWVdGZ3RXRmhZV0Z3aWZTeGNJbk5rYTF3aUlEb2dlMXdpZG1WeWMybHZibHdpSURvZ1hDSTFMalV1TlZ3aWZTeGNJbVJsZG1salpWd2lJRHA3WENKdmNtbGxiblJoZEdsdmJsd2lJRG9nWENKd2IzSjBjbUZwZEZ3aUxGd2lkR2x0WlY5NmIyNWxYQ0lnT2lCY0lpc3dNRG93TUZ3aWZYMD0=";
    XCTAssertEqualObjects([jsonStringContent ogaEncodeStringTo64], expectedbase64jsonStringContent);
}

@end
