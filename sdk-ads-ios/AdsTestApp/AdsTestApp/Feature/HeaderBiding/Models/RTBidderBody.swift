//
//  RTBidderBody.swift
//  AdsTestApp
//
//  Created by Jerome TONNELIER on 14/08/2024.
//

import Foundation
import AppTrackingTransparency
import AdSupport
import OguryAds.Private
import OguryCore.Private

struct RTBidderBody: Encodable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case app
        case at
        case badv
        case bcat
        case device
        case imp
        case regs
        case tmax
        case user
        case test
    }

    var app: App = .init()
    var at: Int = 1
    var badv: [String] = []
    var bcat: [String] = ["IAB25","IAB26","IAB9-9","IAB3-7"]
    var device: Device = .init()
    var imp: [Imp] = [.init()]
    var regs: [String: String] = [:]
    var tmax: Int = 550
    var user: User = .init()
    var test: Int = 0
}

struct Imp: Encodable {
    var banner: Banner
    var bidfloor: Double = 1.12
    var displaymanager: String = "displaymanager"
    var displaymanagerver: String = "5.3.0"
    var exp: Int = 14400
    var id: String = "1"
    var instl: Int = 0
    var secure: Int = 1
    var tagid: String = "AdUnitId"

    init() {
        banner = .init()
    }
}

struct Banner: Encodable {
    var battr: [Int] = [3, 8,9, 10, 14, 17, 6, 7]
    var btype: [String] = []
    var h: Int = 240
    var pos: Int = 1
    var w: Int = 320
}

struct Device: Encodable {
    var connectiontype: Int = 2
    var dnt: Int = 0
    var geo: [String: String] = [:]
    var h: Int = 1334
    var ifa: String { OGCInternal.shared().getAdIdentifier() }
    var ip: String { ipAddress() ?? "x.xx.xxx.xx" }
    var js: Int = 1
    var language: String { Locale.current.language.languageCode?.identifier ?? "en" }
    var make: String = "Apple"
    var model: String {
        #if targetEnvironment(simulator)
        return "iPhone 16 Pro Max"
        #else
        return deviceModel()
        #endif
    }
    var os: String = "ios"
    var osv: String {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        return "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
    }
    var pxratio: Double = 2.0
    var ua: String {
        OGAWebViewUserAgentService.shared().webViewUserAgent ?? "Mozilla/5.0 (Linux; Android 11; Android SDK built for x86 Build/RSR1.210210.001.A1; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36"
    }
    var w: Int { Int(UIScreen.main.bounds.width) }
}

func deviceModel() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    
    return identifier
}

func ipAddress() -> String? {
    var address: String?
    
    // Get list of all interfaces on the device
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    guard let firstAddr = ifaddr else { return nil }
    
    // Iterate through all interfaces
    for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let interface = ptr.pointee
        let addrFamily = interface.ifa_addr.pointee.sa_family
        
        // Check for IPv4 (AF_INET)
        if addrFamily == UInt8(AF_INET) {
            // Convert interface name to a string
            let name = String(cString: interface.ifa_name)
            if name == "en0" { // "en0" is Wi-Fi
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                let result = getnameinfo(
                    interface.ifa_addr,
                    socklen_t(interface.ifa_addr.pointee.sa_len),
                    &hostname,
                    socklen_t(hostname.count),
                    nil,
                    0,
                    NI_NUMERICHOST
                )
                if result == 0 {
                    address = String(cString: hostname)
                }
            }
        }
    }
    
    freeifaddrs(ifaddr)
    return address
}

struct User: Encodable {
    var data: [HBData] = [.init()]
}

struct HBData: Encodable {
    var segment: [[String: String]]
    init() {
        segment = [.init()]
    }
}

struct App: Encodable {
    var bundle: String = "bundle"
    var cat: [String] = ["IAB1", "IAB1-1", "IAB3", "books", "business"]
    var ext: [String: String] = [:]
    var id: String = "AssetKey"
    var publisher: Publisher
    var ver: String = "1.0"

    init() {
        ext = .init()
        publisher = .init()
    }
}

struct Publisher: Encodable {
    var id: String = "04241e0b1cc98976858ce16377c7eef4"
}
