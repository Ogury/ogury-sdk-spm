//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
import AdsCardLibrary
internal import ComposableArchitecture

struct AddFormatView: View {
    @State var value: Int
    let title: String
    let id: UUID
    var numberChanged: (UUID, Int) -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Text(title)
                .font(.adsSubheadline)
            
            Text(String(describing: value))
                .font(.adsTitle2)
            
            HStack(spacing: 4) {
                Button {
                    value -= 1
                    numberChanged(id, value)
                } label: {
                    Image(systemName: "minus")
                        .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
                        .frame(width: 50, height: 50)
                        .background(
                            value == 0
                            ? Color(AdColorPalette.Background.disabled.color).gradient
                            : Color(AdColorPalette.Primary.accentLight.color).gradient
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(value <= 0)
                
                Button {
                    value += 1
                    numberChanged(id, value)
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
                        .frame(width: 50, height: 50)
                        .background(Color(AdColorPalette.Primary.accentLight.color).gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .frame(width: 135, height: 140)
        .background {
            Rectangle()
                .fill(Color(AdColorPalette.Background.primary.color))
                .cornerRadius(12)
        }
        .overlay {
            if value > 0 {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(AdColorPalette.Primary.accent.color), lineWidth: 1)
                    .padding(1)
            }
        }
    }
}

//#Preview {
//    @State var value = 0
//    let adType: AdType<InterstitialAdManager> = .interstitial
//    return ZStack {
//        Color(AdColorPalette.Background.secondary.color).ignoresSafeArea()
//        AddFormatView(value: $value, title: "Inter")
//    }
//}
