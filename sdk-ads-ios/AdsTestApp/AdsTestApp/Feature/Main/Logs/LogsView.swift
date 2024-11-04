//
//  LogsView.swift
//  AdsTestApp
//
//  Created by nicolas perret on 25/10/2024.
//

import SwiftUI
import ComposableArchitecture
import Combine
import AdsCardLibrary

struct LogsView: View {
    let store: StoreOf<LogsFeature>
    @Binding var logsHeight: CGFloat
    @State private var logsSubscription: AnyCancellable?
   
    private let collapsedHeight: CGFloat = 100
    private let halfHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    private let expandedHeight: CGFloat = UIScreen.main.bounds.height * 0.7
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            
            ScrollViewReader { scrollViewProxy in
                VStack(alignment: .center, spacing: 0) {
                    Rectangle()
                        .frame(height: 6)
                        .frame(maxWidth: 100)
                        .foregroundColor(.gray.opacity(0.5))
                        .cornerRadius(3)
                        .padding(.bottom, 8)
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
                    
                    HStack {
                        Text("Logs")
                            .font(.adsTitle2)
                            .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
                            
                            TextField("Filter...", text: viewStore.binding(get:\.filter,
                                                                           send: { .filter($0) } ))
                                .padding(8)
                                .cornerRadius(8)
                            
                            if !viewStore.filter.isEmpty {
                                Button(action: {
                                    viewStore.send(.filter(""))
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color(AdColorPalette.Primary.accent.color))
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(AdColorPalette.Background.placeholder.color))
                        }
                        
                        Button {
                            viewStore.send(.clearLogs)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(Color(AdColorPalette.State.failure.color))
                        }
                    }
                    .padding(.bottom, 8)
                    
                    ScrollView {
                        ForEach(viewStore.logMessages.indices, id: \.self) { index in
                            Text(AttributedString(viewStore.logMessages[index]))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .cornerRadius(8)
                                .overlay (
                                    Divider()
                                        .padding(.leading),
                                    alignment : .bottom
                                )
                                .id(index)
                            Spacer()
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
                .onChange(of: viewStore.logMessages) { _ in
                    if let lastIndex = viewStore.logMessages.indices.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastIndex, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
   
   private func nearestHeight(to height: CGFloat) -> CGFloat {
       let snapPoints = [collapsedHeight, halfHeight, expandedHeight]
       return snapPoints.min(by: { abs($0 - height) < abs($1 - height) }) ?? collapsedHeight
   }
}
