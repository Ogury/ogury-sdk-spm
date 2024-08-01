//
//  RxSettings.swift
//  OguryAdsTestApp
//
//  Created by Pernic on 16/03/2020.
//  Copyright © 2020 co.ogury. All rights reserved.
//

import Foundation
import RxSwift

class RxSettings {

    static var shared = RxSettings()

    init() {
        setAdCells([.logs, .interstitial, .headerBidding(.interstitial)])
    }

    private var adCells = BehaviorSubject(value: AvailableType.allValues)
    private var env = BehaviorSubject(value: Environment.prod)
    private var blacklistCells = BehaviorSubject(value: [String(describing: ThumbnailVC2.self),
                                                         String(describing: ThumbnailVC3.self),
                                                         String(describing: ThumbnailVC4.self)])

    var envObservable: Observable<Environment> {
        return env.asObserver()
    }

    func setEnv(_ env: Environment) {
        self.env.on(.next(env))
    }

    var adCellsObservable: Observable<[AvailableType]> {
        return adCells.asObserver()
    }

    func setAdCells(_ cells: [AvailableType]) {
        adCells.on(.next(cells))
    }

    var blacklistCellsObservable: Observable<[String]> {
        return blacklistCells.asObserver()
    }

    func setBlacklistCells(_ cells: [String]) {
        blacklistCells.on(.next(cells))
    }

}
