//
//  AdTagView.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 04/06/2024.
//

import SwiftUI
import ComposableArchitecture

public struct AdTagList: View {
    let tags: [AdTag]
    public init(tags: [AdTag]) {
        self.tags = tags
    }
    public var body: some View {
        HStack(spacing: 4) {
            ForEach(tags, id: \.name) { tag in
                AdTagView(store: Store(initialState: .init(tag: tag),
                                       reducer: { AdTagFeature() }),
                          displayMode: .fill)
            }
        }
    }
}

#Preview {
    VStack {
        AdTagList(tags: [.ogury, .direct])
        AdTagList(tags: [.max, .headerBidding, .bypass])
        AdTagList(tags: [.dtFairbid, .waterfall, .bypass])
    }
}

struct AdTagView: View {
    let store: StoreOf<AdTagFeature>
    fileprivate var displayMode: AdTagDisplayMode = .fill
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.tagTouched)
            } label: {
                Text(viewStore.tag.name)
                    .font(.adsCaption)
                    .foregroundStyle(
                        displayMode == .fill ? viewStore.tag.textColor  :viewStore.tag.color
                    )
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(
                        displayMode == .fill ? viewStore.tag.color : .clear
                    )
            }
            .clipShape(Capsule())
            .overlay {
                Capsule()
                .stroke(
                    displayMode == .stroke ? viewStore.tag.color : .clear
                )
            }
            .buttonStyle(
                BorderlessButtonStyle()
            )
        }
        .alert(store: self.store.scope(state: \.$alert, action: { .alert($0) }))
    }
}

fileprivate enum AdTagDisplayMode {
    case fill, stroke
}
