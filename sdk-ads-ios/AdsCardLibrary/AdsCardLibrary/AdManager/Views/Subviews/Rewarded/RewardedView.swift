//
//  RewardedView.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 25/09/2023.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//

import SwiftUI
import ComposableArchitecture

struct RewardedView: View {
    let store: StoreOf<RewardedFeature>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            HStack(alignment: .bottom, spacing: 8) {
                AdsTextField(viewStore.$name,
                             placeholder: "Reward name",
                             roundedStyle: false)
                .disabled(true)
                
                AdsTextField(viewStore.$value,
                             placeholder: "Reward name",
                             roundedStyle: false)
                .disabled(true)
            }
//            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
    }
}

#Preview {
    RewardedView(store: Store(initialState: RewardedFeature.State(rewardReceived: true),
                              reducer: { RewardedFeature() }))
}
