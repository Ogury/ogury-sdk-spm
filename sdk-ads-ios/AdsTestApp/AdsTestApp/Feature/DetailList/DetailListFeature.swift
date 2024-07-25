//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import UIKit
import ComposableArchitecture
import AdsCardLibrary

struct DetailListFeature: Reducer {
    var adHostingViewController: UIViewController!
    struct State: Equatable {
        static func == (lhs: DetailListFeature.State, rhs: DetailListFeature.State) -> Bool {
            lhs.adManagers.count == rhs.adManagers.count
        }
        
        var adManagers: [any AdManager]
        var adFormat: AdFormat
        var toolbarVisible: Bool = false
    }
    
    enum Action: Equatable  {
        case deleteCard(id: UUID)
        case showToolbar
        case hideToolbar
        case endEditing
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .deleteCard(id: let id):
                    state.adManagers.removeAll { manager in
                        manager.id == id
                    }
                    return .none
                    
                case .showToolbar:
                    state.toolbarVisible = true
                    return .none
                    
                case .hideToolbar:
                    state.toolbarVisible = false
                    return .none
                    
                case .endEditing:
                    adHostingViewController.view.endEditing(true)
                    return .none
            }
        }
    }
}
