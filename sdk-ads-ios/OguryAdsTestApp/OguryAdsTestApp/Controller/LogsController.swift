//
//  LogsController.swift
//  OguryAdsTestApp
//
//  Created by Pernic on 24/06/2020.
//  Copyright © 2020 co.ogury. All rights reserved.
//

import Foundation
import RxSwift

class LogsController {

    static var shared = LogsController()
    let disposeBag = DisposeBag()
    var logVisible = false

    var logsArray = [String]()

    init() {
        setupRx()
    }

    func setupRx() {
        RxSettings.shared.adCellsObservable.subscribe({ [weak self] cells in
            guard let cells = cells.element, let self = self else {
                return
            }
            self.logVisible = cells.contains(where: { (choice) -> Bool in
                return choice == AvailableType.logs
            })
        }).disposed(by: disposeBag)
    }

    private var logs = BehaviorSubject(value: [String]())

    func logsObserver() -> Observable<[String]> {
        return logs.asObserver()
    }

    func addLogs(_ log: String) {
        logsArray.append(log)
        logs.on(.next(self.logsArray))
        if !logVisible {
            #warning("Replace Toast")
            //Toast(text: log, duration: 1.0).show()
        }
    }

    func clearLogs() {
        logsArray = []
    }

}
