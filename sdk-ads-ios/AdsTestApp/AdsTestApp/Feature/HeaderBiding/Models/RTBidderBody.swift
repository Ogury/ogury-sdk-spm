//
//  RTBidderBody.swift
//  AdsTestApp
//
//  Created by Jerome TONNELIER on 14/08/2024.
//

import Foundation

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
    var ifa: String = "00000000-0000-0000-0000-000000000000"
    var ip: String = "8.25.196.26"
    var js: Int = 1
    var language: String = "en"
    var make: String = "Apple"
    var model: String = "iPhone 11"
    var os: String = "ios"
    var osv: String = "11.4.1"
    var pxratio: Double = 2.0
    var ua: String = "Mozilla/5.0 (Linux; Android 11; Android SDK built for x86 Build/RSR1.210210.001.A1; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36"
    var w: Int = 750
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
