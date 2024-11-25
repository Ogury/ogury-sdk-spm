//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import UIKit
import ComposableArchitecture
import AdsCardLibrary

struct AppFeature: Reducer {
    var adHostingViewController: UIViewController!
    var adDelegate: AdLifeCycleDelegate!
    let cardManager = AdsCardManager()
    let maxHeaderBidable = MaxBidder()
    let dtFairBidHeaderBidable = DTFairBidBidder()
    let unityLevelPlayBidable = UnityLevelPlayBidder()
    
    struct State: Equatable {
        var path = StackState<Path.State>()
        var main = MainFeature.State()
        @PresentationState var alert: AlertState<Action.Alert>?
    }
    
    enum Action: Equatable  {
        case path(StackAction<Path.State, Path.Action>)
        case main(MainFeature.Action)
        case deleteCard(id: UUID)
        case loadCards
        case saveCards
        case importFile(_: URL)
        case alert(PresentationAction<Alert>)
        case forceTestMode(_: Bool)
        case endEditing
        
        enum Alert {
            case cantImportFile
        }
    }
    
    struct Path: Reducer {
        var adHostingViewController: UIViewController!
        var adDelegate: AdLifeCycleDelegate!
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
        Scope(state: \.main,
              action: /Action.main) {
            MainFeature(adHostingViewController: adHostingViewController, adDelegate: adDelegate)
        }
        Reduce { state, action in
            switch action {
                case .alert:
                    return .none
                    
                case .endEditing:
                    adHostingViewController.view.endEditing(true)
                    return .none
                    
                case .path:
                    return .none
                    
                case .main:
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
                    state.main.adFormats = container.retrieveAds(cardManager: cardManager,
                                                                 maxHeaderBidable: maxHeaderBidable, 
                                                                 dtFairBidHeaderBidable: dtFairBidHeaderBidable,
                                                                 unityLevelPlayBidable: unityLevelPlayBidable,
                                                                 viewController: adHostingViewController,
                                                                 view: nil,
                                                                 adDelegate: adDelegate)
                    state.main.setName = container.settings.name
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
                    do {
                        let container = try AdsStorableContainer.load(from: url)
                        let adFormats = container.retrieveAds(cardManager: cardManager,
                                                              maxHeaderBidable: maxHeaderBidable, 
                                                              dtFairBidHeaderBidable: dtFairBidHeaderBidable,
                                                              unityLevelPlayBidable: unityLevelPlayBidable,
                                                              viewController: adHostingViewController,
                                                              view: nil,
                                                              adDelegate: adDelegate) 
                        state.main.adFormats = adFormats
                        state.main.setName = container.settings.name
                        container.save()
                        if container.shouldUpdateAdUnits {
                            return .run { _ in
                                await showNotification(title: "File created on an other os", 
                                                       message: "The file was created using a different os than iOS.\nIn order to allow it to work, the application updated all cards with the default adUnitId for each format",
                                                       notificationType: .warning)
                            }
                        } else {
                            return .none
                        }
                    } catch {
                        state.alert = .cantImportFile
                        return .none
                    }
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
        .forEach(\.path, action: /Action.path) {
            Path(adHostingViewController: adHostingViewController, adDelegate: adDelegate)
        }
    }
    
    private func loadSavedData() throws -> AdsStorableContainer  {
        try AdsStorableContainer.loadSavedData()
    }
}

extension AlertState where Action == AppFeature.Action.Alert {
    static var cantImportFile: AlertState<Action> {
        AlertState {
            TextState("Something went wrong")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState("The file cannot be opened because its content is malformed")
        }
    }
}

extension Array where Element == AdFormat {
    func sorted() -> Array<Element> {
        print("Before sort \(compactMap({ $0.sortPosition }))")
        let sorted = sorted(by: { $0.sortPosition < $1.sortPosition })
        print("After sort \(sorted.compactMap({ $0.sortPosition }))")
        return sorted
    }
}
