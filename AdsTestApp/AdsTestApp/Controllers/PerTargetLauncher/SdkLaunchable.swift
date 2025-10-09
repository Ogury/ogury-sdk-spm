//
//  SdkLaunchable.swift
//  AdsTestApp
//
//  Created by Jerome TONNELIER on 23/04/2025.
//

import UIKit
import AdsCardAdapter

protocol SdkLaunchable {
    static var shared: SdkLaunchable { get }
    var adapter: any AdsCardAdaptable { get }
    var logger: TestAppLogController { mutating get }
    func launch() async
    func startAds(forceStart: Bool) async
    static var assetKey: String { get }
    static var rootViewController: UIViewController! { get set }
}
