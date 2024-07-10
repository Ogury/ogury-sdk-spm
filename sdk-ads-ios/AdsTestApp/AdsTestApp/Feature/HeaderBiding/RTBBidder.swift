//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import AdsCardLibrary
import OguryAds

struct RTBBidder {
    // MARK: - Constants
    let fakeBody = """
        {
          "app": {
            "bundle": "$BUNDLE",
            "cat": [
              "IAB1",
              "IAB1-1",
              "IAB3",
              "books",
              "business"
            ],
            "id": "$ASSET_KEY",
            "publisher": {
              "id": "04241e0b1cc98976858ce16377c7eef4"
            },
            "ver": "1.0"
          },
          "at": 1,
          "badv": [],
          "bcat": [
            "IAB25",
            "IAB26",
            "IAB9-9",
            "IAB3-7"
          ],
          "device": {
            "connectiontype": 2,
            "dnt": 0,
            "geo": $GEO_OBJECT,
            "h": 1334,
            "ifa": "6abe796f-0eed-4130-b416-99939422dc77",
            "ip": "8.25.196.26",
            "js": 1,
            "language": "en",
            "make": "Apple",
            "model": "iPhone 11",
            "os": "ios",
            "osv": "11.4.1",
            "pxratio": 2.0,
            "ua": "Mozilla/5.0 (Linux; Android 11; Android SDK built for x86 Build/RSR1.210210.001.A1; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36",
            "w": 750
          },
          "id": "$AD_UNIT_ID",
          "imp": [
            {
              "banner": {
                "battr": [
                  3,
                  8,
                  9,
                  10,
                  14,
                  17,
                  6,
                  7
                ],
                "btype": [],
                "h": 240,
                "pos": 1,
                "w": 320
              },
              "bidfloor": 1.12,
              "displaymanager": "max",
              "displaymanagerver": "5.3.0",
              "exp": 14400,
              "id": "1",
              "instl": 0,
              "secure": 1,
              "tagid": "$AD_UNIT_ID"
            }
          ],
          "regs": {
            "ext": {}
          },
          "tmax": 550,
          "user": {
            "data": [
              {
                "segment": [
                  {
                    "signal": $TOKEN
                  }
                ]
              }
            ],
            "id": "$AD_UNIT_ID"
          }
        }
        """
    
    enum HeaderBiddingServiceError: LocalizedError {
        case invalidURL
        case networkError(subError: Error)
        case invalidResponse
        case noData
        case invalidData
        case redirection(code: Int)
        case clientError(code: Int)
        case serverError(code: Int)
        case unknownError
        
        var errorDescription: String? {
            let errorDescription: String
            
            switch self {
                case .invalidURL:
                    errorDescription = "Invalid URL"
                case .networkError(let subError):
                    errorDescription = "Network error \(subError)"
                case .invalidResponse:
                    errorDescription = "Invalid response"
                case .noData:
                    errorDescription = "No data received"
                case .invalidData:
                    errorDescription = "Invalid data"
                case .redirection(let code):
                    errorDescription = "Redirection with code \(code)"
                case .clientError(let code):
                    errorDescription = "Client error with code \(code)"
                case .serverError(let code):
                    errorDescription = "Server error with code \(code)"
                case .unknownError:
                    errorDescription = "Unknown error"
            }
            
            return "\(errorDescription) [Recovery suggestion: \(recoverySuggestion ?? "None")]"
        }
        
        var recoverySuggestion: String? {
            var recoverySuggestion: String
            
            switch self {
                    
                case .invalidData:
                    recoverySuggestion = """
                    The ad markup might be malformed (ex: invalid HB token, different asset key between payload and token) OR the backend was not able to fill the request.
                    Contact AdSerbia for debugging.
                    """
                    
                default:
                    recoverySuggestion = "None"
            }
            
            return recoverySuggestion
        }
    }
    
    func description(for error: Error) -> String {
        if let hbError = error as? HeaderBiddingServiceError {
            switch hbError {
                case .networkError(let subError): return "Network error"
                default: return error.localizedDescription
            }
        }
        return error.localizedDescription
    }
    
    typealias HeaderBiddingServiceCompletionHandler = (Result<String, HeaderBiddingServiceError>) -> ()
    
    // MARK: - Functions
    
    func retrieveAdMarkup(assetKey: String,
                          adUnitId: String,
                          country: String?,
                          campaignId: String?,
                          creativeId: String?,
                          dspCreative: String?,
                          dspRegion: DspRegion?,
                          url: URL?,
                          completionHandler: @escaping HeaderBiddingServiceCompletionHandler) {
        // call on Main Thread because of an Xcode warning : bidder token access UIWindowsScene connectedScene
        // which is a Main UI Thread access
        DispatchQueue.main.async {
            guard let headerBiddingURL = url else {
                completionHandler(.failure(.invalidURL))
                return
            }
            
            var request = URLRequest(url: headerBiddingURL)
            request.httpMethod = "POST"
            request.addValue("*/*", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("gzip, deflate, br", forHTTPHeaderField: "Content-Encoding")
            request.addValue("keep-alive", forHTTPHeaderField: "Connection")
            
            // Replace placeholders
            var formattedBody = fakeBody
            formattedBody = formattedBody.replacingOccurrences(of: "$ASSET_KEY", with: assetKey)
            formattedBody = formattedBody.replacingOccurrences(of: "$AD_UNIT_ID", with: adUnitId)
            formattedBody = formattedBody.replacingOccurrences(of: "$GEO_OBJECT", with: self.buildGeoObject(with: country))
           formattedBody = formattedBody.replacingOccurrences(of: "$BUNDLE", with: Bundle.main.bundleIdentifier ?? "co.ogury.sdk.ads.app.devc")
            
           if (campaignId != nil && !campaignId!.isEmpty && dspCreative != nil && !dspCreative!.isEmpty && dspRegion != nil) {
              let cls:AnyClass = OguryTokenService.self
              let sel = NSSelectorFromString("getBidderTokenWithCampaignId:creativeId:dspCreativeId:dspRegion:")
              let meth = class_getClassMethod(cls, sel)
              let imp = method_getImplementation(meth!)
              typealias ClosureType = @convention(c) (AnyObject, Selector, String, String?, String?, String?) -> String
              let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
              let tokenforCampaign = sayHiTo(OguryTokenService.classForCoder(), sel, campaignId!, creativeId, dspCreative, dspRegion!.displayName)
              formattedBody = formattedBody.replacingOccurrences(of: "$TOKEN", with: "\"\(tokenforCampaign)\"")
           } else if (campaignId != nil && !campaignId!.isEmpty) {
                let cls:AnyClass = OguryTokenService.self
                let sel = NSSelectorFromString("getBidderTokenWithCampaignId:creativeId:")
                let meth = class_getClassMethod(cls, sel)
                let imp = method_getImplementation(meth!)
                typealias ClosureType = @convention(c) (AnyObject, Selector, String, String?) -> String
                let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
                let tokenforCampaign = sayHiTo(OguryTokenService.classForCoder(), sel, campaignId!, creativeId)
                formattedBody = formattedBody.replacingOccurrences(of: "$TOKEN", with: "\"\(tokenforCampaign)\"")
            } else {
                let token = OguryTokenService.getBidderToken()
                if let token {
                    formattedBody = formattedBody.replacingOccurrences(of: "$TOKEN", with: "\"\(token)\"")
                } else {
                    formattedBody = formattedBody.replacingOccurrences(of: "$TOKEN", with: "null")
                }
            }
            
            request.httpBody = formattedBody.data(using: .utf8)
            
            URLSession.shared
                .dataTask(with: request) { (data, response, error) in
                    handle(data: data, response: response, error: error, completionHandler: completionHandler)
                }
                .resume()
        }
    }
    
    private func buildGeoObject(with country: String?) -> String {
        switch country {
            case "USA":
                return "{\"country\":\"USA\",\"city\":\"NewYork\"}"
            case "FRA":
                return "{\"country\":\"FRA\",\"city\":\"Paris\"}"
            case "SRB":
                return "{\"country\":\"SRB\",\"city\":\"Belgrade\"}"
            case "JPN":
                return "{\"country\":\"JPN\",\"city\":\"Tokyo\"}"
            default:
                return "{\"country\":\"USA\",\"city\":\"NewYork\"}"
        }
    }
    
    private func handle(data: Data?, response: URLResponse?, error: Error?, completionHandler: HeaderBiddingServiceCompletionHandler) {
        if let error = error {
            completionHandler(.failure(.networkError(subError: error)))
            return
        }
        
        guard let urlResponse = response as? HTTPURLResponse else {
            completionHandler(.failure(.invalidResponse))
            return
        }
        
        switch urlResponse.statusCode {
            case 200..<300:
                guard let data = data, !data.isEmpty else {
                    completionHandler(.failure(.noData))
                    return
                }
                
                guard
                    let bidResponse = try? JSONDecoder().decode(HeaderBiddingResponse.self, from: data),
                    let firstSeatBid = bidResponse.seatbid.first, let firstExt = firstSeatBid.bid.first else {
                    completionHandler(.failure(.invalidData))
                    return
                }
                
                completionHandler(.success(firstExt.ext.signaldata))
                
            case 300..<400:
                completionHandler(.failure(.redirection(code: urlResponse.statusCode)))
                
            case 400..<500:
                completionHandler(.failure(.clientError(code: urlResponse.statusCode)))
                
            case 500..<600:
                completionHandler(.failure(.serverError(code: urlResponse.statusCode)))
                
            default:
                completionHandler(.failure(.unknownError))
        }
    }
    
   func adMarkUp(adUnitId: String,
                 campaignId: String?,
                 creativeId: String?,
                 dspCreative: String?,
                 dspRegion: DspRegion?,
                 url: URL?) async throws -> String? {
        try await withUnsafeThrowingContinuation { continuation in
            retrieveAdMarkup(assetKey: AdSdkLauncher.shared.assetKey,
                             adUnitId: adUnitId,
                             country: "FRA",
                             campaignId: campaignId,
                             creativeId: creativeId,
                             dspCreative: dspCreative,
                             dspRegion: dspRegion, url: url) { result in
                print("👀 \(result)")
                switch result {
                    case let .success(adMarkUp): continuation.resume(returning: adMarkUp)
                    case let .failure(error): continuation.resume(throwing: error)
                }
            }
        }
    }
    
}
