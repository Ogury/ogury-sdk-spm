//
//  OgySpmTestsUITests.swift
//  OgySpmTestsUITests
//
//  Created by Jerome TONNELIER on 25/06/2025.
//

import XCTest

final class OgySpmTestsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor
    func testFlow() throws {
        let app = XCUIApplication()
        app.activate()
        
        let sdkVersion = app.staticTexts["sdkVersion"]
        let oguryWrapperVersion = ProcessInfo.processInfo.environment["OGURY_WRAPPER_VERSION"] ?? "5.1.0"
        XCTContext.runActivity(named: "Print OGURY_WRAPPER_VERSION") { _ in
            print("OGURY_WRAPPER_VERSION = \(oguryWrapperVersion)")
        }
        XCTAssert(sdkVersion.label.range(of: oguryWrapperVersion) != nil)
        
        // consent notice
        let existsPredicate = NSPredicate(format: "exists == 1")
        app.buttons["Show Consent notice"].tap()
        let webView = app.webViews.element
        let webViewExpectation = expectation(for: existsPredicate, evaluatedWith: webView, handler: nil)
        wait(for: [webViewExpectation], timeout: 5)
        let buttons = webView.buttons.matching(identifier: "Consent")
        buttons.element(boundBy: 0).tap()
        
        // start SDK
        app.buttons["Start SDK"].tap()
        // check label after SDK start
        let sdkStarted = app/*@START_MENU_TOKEN@*/.staticTexts["SDK started"]/*[[".otherElements.staticTexts[\"SDK started\"]",".staticTexts[\"SDK started\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let sdkStartedExpectation = expectation(for: existsPredicate, evaluatedWith: sdkStarted, handler: nil)
        wait(for: [sdkStartedExpectation], timeout: 2)
        
        app.buttons["Load"].tap()
        XCTAssert(app.staticTexts["⏱️ Interstitial ad"].exists)
        
        let adLoaded = app/*@START_MENU_TOKEN@*/.staticTexts["✅ Interstitial ad"]/*[[".otherElements.staticTexts[\"✅ Interstitial ad\"]",".staticTexts[\"✅ Interstitial ad\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let adLoadedExpectation = expectation(for: existsPredicate, evaluatedWith: adLoaded, handler: nil)
        wait(for: [adLoadedExpectation], timeout: 5)
        
        app.buttons["Show"].tap()
        let creativeWebView = app.webViews.element
        let creative = creativeWebView.images["creative"]
        let creativeExpectation = expectation(for: existsPredicate, evaluatedWith: creative, handler: nil)
        wait(for: [creativeExpectation], timeout: 5)
    }
}
