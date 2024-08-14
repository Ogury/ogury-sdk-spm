//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import AdsCardLibrary
import OguryAds

class RTBBidder: HeaderBidable {
    // MARK: - Constants
    var body = RTBidderBody()
    var url: URL! { fatalError() }
    
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
        DispatchQueue.main.async { [self] in
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
            var token:String?
            if (campaignId != nil && !campaignId!.isEmpty && dspCreative != nil && !dspCreative!.isEmpty && dspRegion != nil) {
                let cls:AnyClass = OguryTokenService.self
                let sel = NSSelectorFromString("getBidderTokenWithCampaignId:creativeId:dspCreativeId:dspRegion:")
                let meth = class_getClassMethod(cls, sel)
                let imp = method_getImplementation(meth!)
                typealias ClosureType = @convention(c) (AnyObject, Selector, String, String?, String?, String?) -> String
                let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
                token = sayHiTo(OguryTokenService.classForCoder(), sel, campaignId!, creativeId, dspCreative, dspRegion!.displayName)
                
            } else if (campaignId != nil && !campaignId!.isEmpty) {
                let cls:AnyClass = OguryTokenService.self
                let sel = NSSelectorFromString("getBidderTokenWithCampaignId:creativeId:")
                let meth = class_getClassMethod(cls, sel)
                let imp = method_getImplementation(meth!)
                typealias ClosureType = @convention(c) (AnyObject, Selector, String, String?) -> String
                let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
                token = sayHiTo(OguryTokenService.classForCoder(), sel, campaignId!, creativeId)
            } else {
                token = OguryTokenService.getBidderToken()
            }
            
            updateJson(withAdUnit: adUnitId, assetKey: assetKey, country: country, token: token)
            request.httpBody = try? JSONEncoder().encode(body)
            
            URLSession.shared
                .dataTask(with: request) { [self] (data, response, error) in
                    self.handle(data: data, response: response, error: error, completionHandler: completionHandler)
                }
                .resume()
        }
    }
    
    private func buildGeoObject(with country: String?) -> [String: String] {
        switch country {
            case "USA": return ["country":"USA","city":"NewYork"]
            case "FRA": return ["country":"FRA","city":"Paris"]
            case "SRB": return ["country":"SRB","city":"Belgrade"]
            case "JPN": return ["country":"JPN","city":"Tokyo"]
            default: return ["country":"USA","city":"NewYork"]
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
                    let firstSeatBid = bidResponse.seatbid.first, let firstBid = firstSeatBid.bid.first else {
                    completionHandler(.failure(.invalidData))
                    return
                }
                
                guard let token = adMarkUp(from: firstBid) else {
                    completionHandler(.failure(.invalidResponse))
                    return
                }
                completionHandler(.success(token))
                
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
    
    func adMarkUp(from response: HeaderBiddingBid) -> String? {
        fatalError("should be overriden")
    }
    
    func updateJson(withAdUnit adUnit: String, assetKey: String, country: String?, token: String?) {
        body.app.bundle = Bundle.main.bundleIdentifier ?? "co.ogury.sdk.ads.app.devc"
        body.app.id = assetKey
        body.imp[0].tagid = adUnit
        body.device.geo = buildGeoObject(with: country)
    }
    
    func adMarkUp(adUnitId: String,
                  campaignId: String?,
                  creativeId: String?,
                  dspCreative: String?,
                  dspRegion: DspRegion?) async throws -> String? {
        try await withUnsafeThrowingContinuation { continuation in
            retrieveAdMarkup(assetKey: AdSdkLauncher.shared.assetKey,
                             adUnitId: adUnitId,
                             country: "FRA",
                             campaignId: campaignId,
                             creativeId: creativeId,
                             dspCreative: dspCreative,
                             dspRegion: dspRegion,
                             url: url) { result in
//                print("👀 \(result)")
                switch result {
                    case let .success(adMarkUp): continuation.resume(returning: adMarkUp)
                    case let .failure(error): continuation.resume(throwing: error)
                }
            }
        }
    }
}
