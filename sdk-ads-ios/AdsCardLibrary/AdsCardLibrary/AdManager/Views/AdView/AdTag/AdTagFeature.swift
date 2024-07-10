//
//  AdTagFeature.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 04/06/2024.
//

import ComposableArchitecture

struct AdTagFeature: Reducer {
    struct State: Equatable {
        static func == (lhs: AdTagFeature.State, rhs: AdTagFeature.State) -> Bool { lhs.flip == rhs.flip }
        @PresentationState var alert: AlertState<Action.Alert>?
        let tag: AdTag
        var flip = true
    }
    
    enum Action {
        case tagTouched
        case alert(PresentationAction<Alert>)
        enum Alert {}
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .tagTouched:
                    state.alert = AlertState(title: {
                        TextState(state.tag.name)
                    }, message: { [state] in
                        TextState(state.tag.description)
                    })
                    state.flip.toggle()
                    return .none
                    
                case .alert:
                    return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
}
