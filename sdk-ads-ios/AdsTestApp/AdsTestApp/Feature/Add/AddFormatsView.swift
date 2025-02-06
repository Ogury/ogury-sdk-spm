//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
import AdsCardLibrary
import ComposableArchitecture

struct AddFormatView: View {
    var value: Binding<Int>
    let title: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Text(title.capitalized)
                .font(.adsSubheadline)
            
            Text(String(describing: value.wrappedValue))
                .font(.adsTitle2)
            
            HStack(spacing: 4) {
                Button {
                    value.wrappedValue -= 1
                } label: {
                    Image(systemName: "minus")
                        .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
                        .frame(width: 50, height: 50)
                        .background(
                            value.wrappedValue == 0
                            ? Color(AdColorPalette.Background.disabled.color)
                            : Color(AdColorPalette.Primary.accentLight.color)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(value.wrappedValue <= 0)
                
                Button {
                    value.wrappedValue += 1
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
                        .frame(width: 50, height: 50)
                        .background(Color(AdColorPalette.Primary.accentLight.color))
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
            if value.wrappedValue > 0 {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(AdColorPalette.Primary.accent.color), lineWidth: 1)
                    .padding(1)
            }
        }
    }
}

#Preview {
    @State var value = 0
    let adType: AdType<InterstitialAdManager> = .interstitial
    return ZStack {
        Color(AdColorPalette.Background.secondary.color).ignoresSafeArea()
        AddFormatView(value: $value, title: "Inter")
    }
}
