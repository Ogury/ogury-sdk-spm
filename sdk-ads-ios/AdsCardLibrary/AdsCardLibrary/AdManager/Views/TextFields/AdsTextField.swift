//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

import SwiftUI

struct AdsTextField: View {
    let content: () -> any View
    
    var title: String
    var text: Binding<String>
    var titleColor: Color
    var textColor: Color
    init(_ text: Binding<String>,
         placeholder: String,
         titleColor: Color = Color(AdColorPalette.Text.placeholder.color),
         textColor: Color = Color(AdColorPalette.Text.placeholder.color),
         @ViewBuilder content: @escaping () -> some View) {
        self.title = placeholder
        self.text = text
        self.titleColor = titleColor
        self.textColor = textColor
        self.content = content
    }
    
    init(_ text: Binding<String>,
         placeholder: String,
         titleColor: Color = Color(AdColorPalette.Text.placeholder.color),
         textColor: Color = Color(AdColorPalette.Text.placeholder.color)) {
        self = .init(text,
                     placeholder: placeholder,
                     titleColor: titleColor,
                     textColor: textColor,
                     content: {
            EmptyView()
        })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: -2) {
            HStack(spacing:2) {
                Text(title)
                    .foregroundStyle(titleColor)
                .font(.adsTitle3)
                
                Spacer()
                
                AnyView(content())
            }
            
            TextField("", text: text)
                .frame(minHeight: 40)
                .padding(.vertical, 1)
                .font(.adsBody)
                .foregroundStyle(textColor)
                .textFieldStyle(.roundedBorder)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    @State var text = "435264"
    return ZStack {
        //        Color.black
        VStack {
            AdsTextField($text, placeholder: "Ad init ID")
                .padding()
            
            
            AdsTextField($text, placeholder: "Ad init ID", content: {
                Text("test mode")
                    .font(.adsCaption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.red)
                    .foregroundStyle(Color.white)
                    .clipShape(Capsule())
            })
                .padding()
        }
    }
}
