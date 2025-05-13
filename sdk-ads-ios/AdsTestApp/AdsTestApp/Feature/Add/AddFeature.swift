//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
internal import ComposableArchitecture
import AdsCardLibrary
import AdsCardAdapter

@Reducer
struct AddFeature {
    @ObservableState
    struct State: Equatable {
        static func == (lhs: AddFeature.State, rhs: AddFeature.State) -> Bool {
            lhs.sections.id == rhs.sections.id && lhs.formatToLoad == rhs.formatToLoad
        }
        
        var sections: IdentifiedArrayOf<AdAdapterFormatSection> = []
        /// The key here is the UUID of the AdAdapterFormat
        var formatToLoad: [UUID: Int]
        
        init() {
            let formats = SdkLauncher.shared.adapter.availableAdFormats
            sections = IdentifiedArrayOf<AdAdapterFormatSection>(uniqueElements: formats)
            formatToLoad = Dictionary(uniqueKeysWithValues: formats.flatMap { $0.formats.map { ($0.id, 0) } })
        }
    }
    
    enum Action: Equatable  {
        static func == (lhs: AddFeature.Action, rhs: AddFeature.Action) -> Bool {
            switch (lhs, rhs) {
                case let (.setSections(lhsSection), .setSections(rhsSection)): return lhsSection.id == rhsSection.id
                case let (.setValueForFormat(lhsValue, lhsId), .setValueForFormat(rhsValue, rhsId)): return lhsId == rhsId && lhsValue == rhsValue
                default: return false
            }
        }
        
        case setSections(_: IdentifiedArrayOf<AdAdapterFormatSection>)
        case setValueForFormat(_: Int, _: UUID)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case let .setSections(sections):
                    state.sections = sections
                    return .none
                    
                case let .setValueForFormat(value, id):
                    state.formatToLoad[id] = max(min(value, 10), 0)
                    return .none
            }
        }
    }
}
