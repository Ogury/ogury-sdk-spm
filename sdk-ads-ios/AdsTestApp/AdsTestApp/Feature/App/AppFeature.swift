//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import UIKit
internal import ComposableArchitecture
import AdsCardLibrary

struct AppFeature: Reducer {
    var adHostingViewController: UIViewController!
    var adDelegate: (AdLifeCycleDelegate & ApplicationDelegate)!
    let cardManager = AdsCardManager()
    
    struct State: Equatable {
        var path = StackState<Path.State>()
        var main = MainFeature.State()
        var logs = LogsFeature.State()
    }
    
    enum Action: Equatable  {
        case path(StackAction<Path.State, Path.Action>)
        case main(MainFeature.Action)
        case logs(LogsFeature.Action)
        case deleteCard(id: UUID)
        case loadCards
        case saveCards
        case importFile(_: URL)
        case forceTestMode(_: Bool)
        case focusLogs(on: String)
        case endEditing
    }
    
    struct Path: Reducer {
        var adHostingViewController: UIViewController!
        var adDelegate: (AdLifeCycleDelegate & ApplicationDelegate)!
        enum State: Equatable {
            case main(MainFeature.State)
            case detail(DetailListFeature.State)
        }
        enum Action: Equatable {
            case main(MainFeature.Action)
            case detail(DetailListFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(
                state: /State.main,
                action: /Action.main) {
                    MainFeature(adHostingViewController: adHostingViewController, adDelegate: adDelegate)
                }
            Scope(
                state: /State.detail,
                action: /Action.detail) {
                    DetailListFeature(adHostingViewController: adHostingViewController)
                }
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.logs,
             action: /Action.logs) {
            LogsFeature()
        }
        Scope(state: \.main,
              action: /Action.main) {
            MainFeature(adHostingViewController: adHostingViewController, adDelegate: adDelegate)
        }
        Reduce { state, action in
            switch action {
                case .endEditing:
                    adHostingViewController.view.endEditing(true)
                    return .none
                    
                case .path:
                    return .none
                    
                case .main, .logs:
                    return .none
                    
                case let .deleteCard(id):
                    if let idElement = state.path.ids.last {
                        return .run { send in
                            await send(.main(.deleteCard(id: id)))
                            await send(.path(.element(id: idElement, action: .detail(.deleteCard(id: id)))))
                        }
                    }
                    return .send(.main(.deleteCard(id: id)))
                    
                case .loadCards:
                    guard let container = try? loadSavedData() else { return .none }
                    //TODO: 🍀 Fix import
//                    state.main.adFormats = container.retrieveAds(cardManager: cardManager,
//                                                                 maxHeaderBidable: maxHeaderBidable, 
//                                                                 dtFairBidHeaderBidable: dtFairBidHeaderBidable,
//                                                                 unityLevelPlayBidable: unityLevelPlayBidable,
//                                                                 viewController: adHostingViewController,
//                                                                 view: nil,
//                                                                 adDelegate: adDelegate)
//                    state.main.setName = container.settings.name
                    return .none
                    
                case .saveCards:
                    return .send(.main(.saveCards))
               
                case let .forceTestMode(enable):
                    state
                        .main
                        .adFormats
                        .compactMap({ $0.value })
                        .flatMap({ $0 })
                        .forEach({ adManager in
                            adManager.updateCard(events: [.forceTestMode(enable)])
                        })
                    return .none
                    
                case let .importFile(url):
                    return .send(.main(.importFile(url)))
                    
                case let .focusLogs(cardId):
                    state.logs.filter = cardId
                    return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path(adHostingViewController: adHostingViewController, adDelegate: adDelegate)
        }
    }
    
    private func loadSavedData() throws -> AdsStorableContainer  {
        try AdsStorableContainer.loadSavedData()
    }
}
