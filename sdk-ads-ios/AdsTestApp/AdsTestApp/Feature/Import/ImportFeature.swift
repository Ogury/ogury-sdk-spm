//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import UIKit
internal import ComposableArchitecture

struct ImportFeature: Reducer {
    struct State: Equatable {
        @BindingState var jsonText: String = ""  {
            didSet {
                if let data = jsonText.data(using: .utf8),
                   let _ = try? JSONSerialization.jsonObject(with: data) {
                    validJson = true
                } else {
                    validJson = false
                }
            }
        }

        var validJson = false
    }
    
    enum Action: BindableAction, Equatable  {
        case importButtonTapped(_: String)
        case binding(BindingAction<State>)
        case pasteFromClipboard
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.jsonText) { oldValue, newValue in
                Reduce() { state, action in
                    if let data = newValue.data(using: .utf8),
                       let _ = try? JSONSerialization.jsonObject(with: data) {
                        state.validJson = true
                    } else {
                        state.validJson = false
                    }
                    return .none
                }
            }
        Reduce { state, action in
            switch action {
                case .importButtonTapped:
                    return .none
                    
                case .binding:
                    return .none
                    
                case .pasteFromClipboard:
                    if let str = UIPasteboard.general.string {
                        state.jsonText = str
                    }
                    return .none
            }
        }
    }
}
