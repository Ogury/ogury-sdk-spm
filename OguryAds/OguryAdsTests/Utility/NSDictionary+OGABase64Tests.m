//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDictionary+OGABase64.h"
#import <OCMock/OCMock.h>
#import "OGATokenConstants.h"

@interface NSDictionary_OGABase64Tests : XCTestCase

@end

@implementation NSDictionary_OGABase64Tests

- (void)testOgaEncodeToBase64 {
    NSDictionary *myDictionnary = @{
        OGATokenApplication : @{
            OGATokenAssetKey : @"272506",
            OGATokenInstanceToken : @"00000000-1111-3333-1598-000000000000"
        },
        OGATokenSDK : @{
            OGATokenModuleVersion : @"3.0.0"
        },
        OGATokenDevice : @{
            OGATokenScreen : @{
                OGATokenOrientation : @"portrait",
            },
            OGATokenSettings : @{
                OGATokenTimeZone : @"+00:00"
            }
        }
    };
    NSString *expectedbase64 = @"eyJhcHAiOnsiYXNzZXRfa2V5IjoiMjcyNTA2IiwiaW5zdGFuY2VfdG9rZW4iOiIwMDAwMDAwMC0xMTExLTMzMzMtMTU5OC0wMDAwMDAwMDAwMDAifSwic2RrIjp7Im1vZHVsZV92ZXJzaW9uIjoiMy4wLjAifSwiZGV2aWNlIjp7InNldHRpbmdzIjp7InRpbWVfem9uZSI6IiswMDowMCJ9LCJzY3JlZW4iOnsib3JpZW50YXRpb24iOiJwb3J0cmFpdCJ9fX0=";
    XCTAssertEqualObjects([myDictionnary ogaEncodeToBase64], expectedbase64);
}

- (void)testOgaEncodeStringTo64Error {
    NSDictionary *myDictionnary = OCMPartialMock(@{@"test" : @"test"});
    id jsonSerializationMock = [OCMockObject mockForClass:[NSJSONSerialization class]];
    [[[[jsonSerializationMock stub] classMethod] andReturn:nil] dataWithJSONObject:[OCMArg any] options:NSJSONWritingFragmentsAllowed error:[OCMArg anyObjectRef]];
    NSString *result = [myDictionnary ogaEncodeToBase64];
    XCTAssertEqualObjects(result, @"");
}

- (void)testOgaDecodeToBase64 {
    NSDictionary *myDictionnary = @{@"ad" : @[ @{
        @"format" : @{
            @"webview_base_url" : @"http://www.ogyfmts.com/",
            @"mraid_download_url" : @"https://mraid.presage.io/bf6abb6/mraid.js",
            @"params" : @[ @{
                @"name" : @"zones",
                @"value" : @[
                    @{
                        @"name" : @"controller",
                        @"url" : @"https://staging.litecdn.com/2021-10-13-a82eb0a8/formats/mraid-wrapper/index.html",
                        @"size" : @{
                            @"width" : @-1,
                            @"height" : @-1
                        }
                    }
                ]
            } ]
        },
        @"advertiser" : @{
            @"id" : @137,
            @"name" : @"Philips"
        },
        @"ad_content" : @"<html>  <head>  <meta charset=\"UTF-8\">  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=no\">  <link rel=\"icon\" type=\"image/png\" href=\"data:image/png;base64,iVBORw0KGgo=\">  </head>  <body>  <div id=\"root\">  </div>  <script src=\"mraid.js\"></script>  <script src=\"https://ms-ads.staging.presage.io/mraid?dsp=ogury&t=f06d9421-80bd-40f1-a0cb-f110dd1df312&imp=f33814be-c6c4-4b4b-a3fe-9305b6e35411&oc_uuid=ba4e84d5-50db-4216-89fb-8454be5619ca&ak=272506&u_do=false&u_id=00000000-0000-0000-0000-000000000000&a_sdk=3.0.0-beta-1.2.0&auid=272506_default&conn=ALL&u_os=ios&a_b=co.ogury.ads.SwiftPresageTest&a_n=iOS%20New%20Test%20App&autype=interstitial&a_ex=ogury&t_a=true&bid_hash=&dmn=&pg=&d_m=x86_64&d_ty=mobile&u_tk=5fbb353f-0b4e-4fb2-8a52-832dadb1d1bd&aud=true&dualad=&g=&c_s=\"></script>  </body>  </html>",
        @"id" : @"f33814be-c6c4-4b4b-a3fe-9305b6e35411",
        @"campaign_id" : @34717,
        @"ad_unit" : @{
            @"id" : @"272506_default",
            @"type" : @"interstitial"
        },
        @"sdk_close_button_url" : @"https://ms-ads-events.staging.presage.io/creative?e=sdk_close_button&imp=f33814be-c6c4-4b4b-a3fe-9305b6e35411&oc_id=34717&ak=272506&u_id=00000000-0000-0000-0000-000000000000&a_sdk=3.0.0-beta-1.2.0&u_os=ios&a_b=co.ogury.ads.SwiftPresageTest&a_n=iOS%20New%20Test%20App",
        @"ad_keep_alive" : @YES,
        @"params" : @[],
        @"sdk_background_color" : @"#000000",
        @"is_impression" : @YES
    } ]};
    NSError *error = nil;
    NSDictionary *dict = [NSDictionary ogaDecodeFromBase64:@"eyJhZCI6W3siZm9ybWF0Ijp7InBhcmFtcyI6W3sibmFtZSI6InpvbmVzIiwidmFsdWUiOlt7Im5hbWUiOiJjb250cm9sbGVyIiwidXJsIjoiaHR0cHM6XC9cL3N0YWdpbmcubGl0ZWNkbi5jb21cLzIwMjEtMTAtMTMtYTgyZWIwYThcL2Zvcm1hdHNcL21yYWlkLXdyYXBwZXJcL2luZGV4Lmh0bWwiLCJzaXplIjp7IndpZHRoIjotMSwiaGVpZ2h0IjotMX19XX1dLCJ3ZWJ2aWV3X2Jhc2VfdXJsIjoiaHR0cDpcL1wvd3d3Lm9neWZtdHMuY29tXC8iLCJtcmFpZF9kb3dubG9hZF91cmwiOiJodHRwczpcL1wvbXJhaWQucHJlc2FnZS5pb1wvYmY2YWJiNlwvbXJhaWQuanMifSwiY2FtcGFpZ25faWQiOjM0NzE3LCJwYXJhbXMiOltdLCJhZF9jb250ZW50IjoiPGh0bWw+ICA8aGVhZD4gIDxtZXRhIGNoYXJzZXQ9XCJVVEYtOFwiPiAgPG1ldGEgbmFtZT1cInZpZXdwb3J0XCIgY29udGVudD1cIndpZHRoPWRldmljZS13aWR0aCwgaW5pdGlhbC1zY2FsZT0xLjAsIHVzZXItc2NhbGFibGU9bm9cIj4gIDxsaW5rIHJlbD1cImljb25cIiB0eXBlPVwiaW1hZ2VcL3BuZ1wiIGhyZWY9XCJkYXRhOmltYWdlXC9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvPVwiPiAgPFwvaGVhZD4gIDxib2R5PiAgPGRpdiBpZD1cInJvb3RcIj4gIDxcL2Rpdj4gIDxzY3JpcHQgc3JjPVwibXJhaWQuanNcIj48XC9zY3JpcHQ+ICA8c2NyaXB0IHNyYz1cImh0dHBzOlwvXC9tcy1hZHMuc3RhZ2luZy5wcmVzYWdlLmlvXC9tcmFpZD9kc3A9b2d1cnkmdD1mMDZkOTQyMS04MGJkLTQwZjEtYTBjYi1mMTEwZGQxZGYzMTImaW1wPWYzMzgxNGJlLWM2YzQtNGI0Yi1hM2ZlLTkzMDViNmUzNTQxMSZvY191dWlkPWJhNGU4NGQ1LTUwZGItNDIxNi04OWZiLTg0NTRiZTU2MTljYSZhaz0yNzI1MDYmdV9kbz1mYWxzZSZ1X2lkPTAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMCZhX3Nkaz0zLjAuMC1iZXRhLTEuMi4wJmF1aWQ9MjcyNTA2X2RlZmF1bHQmY29ubj1BTEwmdV9vcz1pb3MmYV9iPWNvLm9ndXJ5LmFkcy5Td2lmdFByZXNhZ2VUZXN0JmFfbj1pT1MlMjBOZXclMjBUZXN0JTIwQXBwJmF1dHlwZT1pbnRlcnN0aXRpYWwmYV9leD1vZ3VyeSZ0X2E9dHJ1ZSZiaWRfaGFzaD0mZG1uPSZwZz0mZF9tPXg4Nl82NCZkX3R5PW1vYmlsZSZ1X3RrPTVmYmIzNTNmLTBiNGUtNGZiMi04YTUyLTgzMmRhZGIxZDFiZCZhdWQ9dHJ1ZSZkdWFsYWQ9Jmc9JmNfcz1cIj48XC9zY3JpcHQ+ICA8XC9ib2R5PiAgPFwvaHRtbD4iLCJpZCI6ImYzMzgxNGJlLWM2YzQtNGI0Yi1hM2ZlLTkzMDViNmUzNTQxMSIsImlzX2ltcHJlc3Npb24iOnRydWUsImFkdmVydGlzZXIiOnsiaWQiOjEzNywibmFtZSI6IlBoaWxpcHMifSwiYWRfa2VlcF9hbGl2ZSI6dHJ1ZSwiYWRfdW5pdCI6eyJpZCI6IjI3MjUwNl9kZWZhdWx0IiwidHlwZSI6ImludGVyc3RpdGlhbCJ9LCJzZGtfY2xvc2VfYnV0dG9uX3VybCI6Imh0dHBzOlwvXC9tcy1hZHMtZXZlbnRzLnN0YWdpbmcucHJlc2FnZS5pb1wvY3JlYXRpdmU/ZT1zZGtfY2xvc2VfYnV0dG9uJmltcD1mMzM4MTRiZS1jNmM0LTRiNGItYTNmZS05MzA1YjZlMzU0MTEmb2NfaWQ9MzQ3MTcmYWs9MjcyNTA2JnVfaWQ9MDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwJmFfc2RrPTMuMC4wLWJldGEtMS4yLjAmdV9vcz1pb3MmYV9iPWNvLm9ndXJ5LmFkcy5Td2lmdFByZXNhZ2VUZXN0JmFfbj1pT1MlMjBOZXclMjBUZXN0JTIwQXBwIiwic2RrX2JhY2tncm91bmRfY29sb3IiOiIjMDAwMDAwIn1dfQ==" error:&error];
    XCTAssertEqualObjects(dict, myDictionnary);
}

- (void)testOgaDecodeToBase64EmptyAdMarkup {
    NSError *error = nil;
    NSString *jsonString;
    NSDictionary *dict = [NSDictionary ogaDecodeFromBase64:jsonString error:&error];
    XCTAssertNil(dict);
    XCTAssertNotNil(error);
}

@end
