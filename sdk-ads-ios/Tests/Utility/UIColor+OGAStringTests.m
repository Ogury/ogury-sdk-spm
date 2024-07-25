//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "UIColor+OGAString.h"

@interface UIColorOGAStringTests : XCTestCase

@end

@implementation UIColorOGAStringTests

- (void)testColorFromStringBlack {
    UIColor *color = [UIColor colorFromString:@"#000000"];
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertNotNil(color);
    XCTAssertEqual(alpha, 1);
    XCTAssertEqual(blue, 0);
    XCTAssertEqual(green, 0);
    XCTAssertEqual(red, 0);
}

- (void)testColorFromStringNil {
    UIColor *color = [UIColor colorFromString:nil];
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertNotNil(color);
    XCTAssertEqual(alpha, 1);
    XCTAssertEqual(blue, 0);
    XCTAssertEqual(green, 0);
    XCTAssertEqual(red, 0);
}

- (void)testColorFromStringWhiteWithThreePart1 {
    UIColor *color = [UIColor colorFromString:@"#fff"];
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertNotNil(color);
    XCTAssertEqual(alpha, 1);
    XCTAssertEqual(blue, 1);
    XCTAssertEqual(green, 1);
    XCTAssertEqual(red, 1);
}

- (void)testColorFromStringWhiteWithThreePart2 {
    UIColor *color = [UIColor colorFromString:@"#333"];
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertNotNil(color);
    XCTAssertEqual(alpha, 1);
    XCTAssertEqual(blue, 0.2);
    XCTAssertEqual(green, 0.2);
    XCTAssertEqual(red, 0.2);
}

- (void)testColorFromStringBadTwo {
    UIColor *color = [UIColor colorFromString:@"dsf"];
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertNotNil(color);
    XCTAssertEqual(alpha, 1);
    XCTAssertEqual(blue, 0);
    XCTAssertEqual(green, 0);
    XCTAssertEqual(red, 0);
}

- (void)testColorFromStringBadThree {
    UIColor *color = [UIColor colorFromString:@"#ZZZ"];
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertNotNil(color);
    XCTAssertEqual(alpha, 1);
    XCTAssertEqual(blue, 0);
    XCTAssertEqual(green, 0);
    XCTAssertEqual(red, 0);
}

- (void)testColorFromStringBadFour {
    UIColor *color = [UIColor colorFromString:@""];
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertNotNil(color);
    XCTAssertEqual(alpha, 1);
    XCTAssertEqual(blue, 0);
    XCTAssertEqual(green, 0);
    XCTAssertEqual(red, 0);
}

- (void)testColorFromStringBadFive {
    UIColor *color = [UIColor colorFromString:@"ddsf"];
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertNotNil(color);
    XCTAssertEqual(alpha, 1);
    XCTAssertEqual(blue, 0);
    XCTAssertEqual(green, 0);
    XCTAssertEqual(red, 0);
}

- (void)testColorFromStringWhite {
    UIColor *color = [UIColor colorFromString:@"#ffffff"];
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertNotNil(color);
    XCTAssertEqual(alpha, 1);
    XCTAssertEqual(blue, 1);
    XCTAssertEqual(green, 1);
    XCTAssertEqual(red, 1);
}

- (void)testColorFromStringCustom {
    UIColor *color = [UIColor colorFromString:@"#333333"];
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertNotNil(color);
    XCTAssertEqual(alpha, 1);
    XCTAssertEqual(blue, 0.2);
    XCTAssertEqual(green, 0.2);
    XCTAssertEqual(red, 0.2);
}

- (void)testColorFromStringBlackWithAlpha {
    UIColor *color = [UIColor colorFromString:@"#00000000"];
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertNotNil(color);
    XCTAssertEqual(alpha, 0);
    XCTAssertEqual(blue, 0);
    XCTAssertEqual(green, 0);
    XCTAssertEqual(red, 0);
}

- (void)testColorFromStringWhiteWithAlpha {
    UIColor *color = [UIColor colorFromString:@"#00ffffff"];
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertNotNil(color);
    XCTAssertEqual(alpha, 0);
    XCTAssertEqual(blue, 1);
    XCTAssertEqual(green, 1);
    XCTAssertEqual(red, 1);
}

- (void)testColorFromStringCustomWithAlpha {
    UIColor *color = [UIColor colorFromString:@"#33333333"];
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertNotNil(color);
    XCTAssertEqual(alpha, 0.2);
    XCTAssertEqual(blue, 0.2);
    XCTAssertEqual(green, 0.2);
    XCTAssertEqual(red, 0.2);
}

@end
