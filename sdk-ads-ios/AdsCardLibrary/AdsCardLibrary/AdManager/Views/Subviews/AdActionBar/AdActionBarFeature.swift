//
//  AdActionBarFeature.swift
//  AdCard
//
//  Created by Jerome TONNELIER on 19/07/2023.
//

internal import ComposableArchitecture

struct AdActionBarFeature: Reducer {
    struct State: Equatable {
        var qaLabel: String
    }
    
    enum Action: Equatable  {
        case loadButtonTapped
        case showButtonTapped
        case loadAndShowButtonTapped
        case deleteButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .loadButtonTapped:
                    return .none
                    
                case .showButtonTapped:
                    return .none
                    
                case .loadAndShowButtonTapped:
                    return .none
                    
                case .deleteButtonTapped:
                    return .none
                    
            }
        }
    }
}
