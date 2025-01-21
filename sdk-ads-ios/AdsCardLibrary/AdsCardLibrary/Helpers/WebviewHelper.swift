//
//  WebviewHelper.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 17/01/2025.
//

import Foundation
import WebKit

struct WebviewHelper {
    func kill(webview: WKWebView) async throws -> Any {
        let crashScript = "let largeArray = Array(1e9).fill(0);"
        return try await webview.evaluateJavaScript(crashScript)
    }
}
