//
//  RewardedFeature.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 25/09/2023.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//

import UIKit
internal import ComposableArchitecture

struct RewardedOptions: Equatable {
    var name: String = ""
    var value: String = ""
    var received = false
}

struct RewardedFeature: Reducer {
    struct State: Equatable {
        @BindingState var name: String = ""
        @BindingState var value: String = ""
        var rewardReceived = false
    }
    
    enum Action: BindableAction, Equatable  {
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                case .binding:
                    return .none
            }
        }
    }
}
