//
//  AdTagView.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 04/06/2024.
//

import SwiftUI
import ComposableArchitecture

public struct AdTagList: View {
    public enum TagSize {
        case small, `default`
    }
    let tags: [OguryAdTag]
    var size: TagSize = .default
    public init(tags: [OguryAdTag], size: TagSize = .default) {
        self.tags = tags
        self.size = size
    }
    public var body: some View {
        HStack(spacing: 4) {
            ForEach(tags, id: \.name) { tag in
                AdTagView(store: Store(initialState: .init(
                    tag: tag,
                    size: size
                ), reducer: { AdTagFeature() }))
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
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.tagTouched)
            } label: {
                Text(viewStore.tag.name)
                    .font(viewStore.size == .small ? .adsCaptionSmall : .adsCaption)
                    .foregroundStyle(
                        viewStore.tag.displayMode == .fill ? viewStore.tag.textColor  :viewStore.tag.color
                    )
                    .padding(.vertical, viewStore.size == .small ? 2 : 4)
                    .padding(.horizontal, viewStore.size == .small ? 5 : 10)
                    .background(
                        viewStore.tag.displayMode == .fill ? viewStore.tag.color : .clear
                    )
            }
            .clipShape(Capsule())
            .overlay {
                Capsule()
                .stroke(
                    viewStore.tag.displayMode == .stroke ? viewStore.tag.color : .clear
                )
            }
            .buttonStyle(
                BorderlessButtonStyle()
            )
        }
        .alert(store: self.store.scope(state: \.$alert, action: { .alert($0) }))
    }
}
