//
//  LogsView.swift
//  AdsTestApp
//
//  Created by nicolas perret on 25/10/2024.
//

import SwiftUI
import ComposableArchitecture
import Combine

struct LogsView: View {
    let store: StoreOf<LogsFeature>
    @Binding var logsHeight: CGFloat
    @State private var logsSubscription: AnyCancellable?
   
    private let collapsedHeight: CGFloat = 100
    private let halfHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    private let expandedHeight: CGFloat = UIScreen.main.bounds.height * 0.7
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
           VStack(alignment: .center, spacing: 0) {
              Rectangle()
                  .frame(height: 6)
                  .frame(maxWidth: 100)
                  .foregroundColor(.gray.opacity(0.5))
                  .cornerRadius(3)
                  .padding(.vertical, 8)
                  .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newHeight = logsHeight - value.translation.height
                                logsHeight = max(collapsedHeight, min(newHeight, expandedHeight))
                            }
                            .onEnded { _ in
                                withAnimation {
                                    logsHeight = nearestHeight(to: logsHeight)
                                }
                            }
                    )
              ScrollView {
                 VStack(alignment: .leading, spacing: 0) {
                    HStack {
                       Text("Logs")
                          .font(.title2)
                       Spacer()
                       Button {
                          viewStore.send(.clearLogs)
                       } label: {
                          Image(systemName: "trash")
                       }
                    }
                    ForEach(viewStore.logMessages.indices, id: \.self) { index in
                       Text(AttributedString(viewStore.logMessages[index]))
                          .padding(.horizontal)
                          .padding(.vertical, 8)
                          .cornerRadius(8)
                          .overlay (
                             Divider()
                                .padding(.leading),
                             alignment : .bottom
                          )
                    }
                 }
              }
           }
           .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .onAppear {
               logsSubscription = TestAppLogController.shared.logger.logs
                  .receive(on: DispatchQueue.main)
                  .sink { logMessages in
                     viewStore.send(.receiveLog(logMessages))
                  }
            }
            .onDisappear {
                logsSubscription?.cancel()
                logsSubscription = nil
            }
        }
    }
   
   private func nearestHeight(to height: CGFloat) -> CGFloat {
       let snapPoints = [collapsedHeight, halfHeight, expandedHeight]
       return snapPoints.min(by: { abs($0 - height) < abs($1 - height) }) ?? collapsedHeight
   }
}
