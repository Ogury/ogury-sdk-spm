//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import UIKit
internal import ComposableArchitecture

@Reducer
struct WhatsNewFeature {
    
    @ObservableState
    struct State: Equatable {
        var markdownString = ""
        var showConfetti = false
    }
    
    enum Action: Equatable  {
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
