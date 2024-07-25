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
            HStack(spacing: 15) {
                AdsTextField(viewStore.$name, 
                             placeholder: "Reward name",
                             titleColor: Color(viewStore.rewardReceived 
                                               ? AdColorPalette.Text.primary(onAccent: false).color
                                               : AdColorPalette.Text.placeholder.color),
                             textColor: Color(viewStore.rewardReceived
                                              ? AdColorPalette.Text.placeholder.color
                                              : AdColorPalette.Text.placeholder.color))
                    .disabled(true)
                
                AdsTextField(viewStore.$value, 
                             placeholder: "Reward value",
                             titleColor: Color(viewStore.rewardReceived
                                               ? AdColorPalette.Text.primary(onAccent: false).color
                                               : AdColorPalette.Text.placeholder.color),
                             textColor: Color(viewStore.rewardReceived
                                              ? AdColorPalette.Text.placeholder.color
                                              : AdColorPalette.Text.placeholder.color))
                    .disabled(true)
            }
            .padding()
            .background {
                Rectangle()
                    .fill(Color(viewStore.rewardReceived ? AdColorPalette.Primary.accentLight.color : AdColorPalette.Background.disabled.color))
                    .cornerRadius(8)
                
            }
            .padding(12)
        }
    }
}

#Preview {
    RewardedView(store: Store(initialState: RewardedFeature.State(rewardReceived: true),
                              reducer: { RewardedFeature() }))
}
