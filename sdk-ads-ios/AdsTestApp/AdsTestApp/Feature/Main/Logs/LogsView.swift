import SwiftUI
import ComposableArchitecture
import Combine
import AdsCardLibrary

struct LogsView: View {
    let store: StoreOf<LogsFeature>
    @Binding var logsHeight: CGFloat
    @State private var previousHeight: CGFloat = 0
    @State private var logsSubscription: AnyCancellable?
    @Binding var isSearching: Bool
    @FocusState private var isTextFieldFocused: Bool
    
    private let collapsedHeight: CGFloat = 150
    private let halfHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    private let fullHeight: CGFloat = UIScreen.main.bounds.height * 0.84
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollViewReader { scrollViewProxy in
                VStack(alignment: .center, spacing: 0) {
                    if !isSearching {
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
                                        logsHeight = max(collapsedHeight, min(newHeight, fullHeight))
                                    }
                                    .onEnded { _ in
                                        withAnimation {
                                            logsHeight = nearestHeight(to: logsHeight)
                                            previousHeight = logsHeight
                                        }
                                    }
                            )
                            .accessibilityLabel("LogSheetDragView")
                        
                        ScrollView {
                            ForEach(viewStore.logMessages.indices, id: \.self) { index in
                                let str = viewStore.logMessages[index]
                                Text(AttributedString(str))
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
                                    .accessibilityLabel("LogItem#\(index)")
                                    .accessibilityValue("\(str)")
                                Spacer()
                            }
                        }
                        .padding(.bottom, 8)
                        .accessibilityLabel("LogView")
                        
                        HStack {
                            HStack(spacing:2) {
                                Text("Logs")
                                    .font(.adsTitle2)
                                    .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
                                
                                AdTagList(tags: [.beta], size: .small)
                            }
                            
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
                                
                                Button(action: {
                                    isSearching = true
                                }) {
                                    Text(viewStore.filter.isEmpty ? "Filter logs..." : viewStore.filter)
                                        .foregroundColor(viewStore.filter.isEmpty ? .gray : .primary)
                                        .padding(8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .accessibilityLabel("LogSearchButton")
                                
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
                            
                            ShareLink(item: viewStore.logsAsString) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundStyle(
                                        Color(viewStore.logMessages.isEmpty
                                              ? AdColorPalette.Background.placeholder.color
                                              : AdColorPalette.Primary.accent.color)
                                    )
                            }
                            .disabled(viewStore.logMessages.isEmpty)
                            .accessibilityLabel("LogShareButton")
                            
                            Button {
                                viewStore.send(.clearLogs)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(Color(AdColorPalette.State.failure.color))
                            }
                            .accessibilityLabel("LogClearButton")
                        }
                        .padding(.bottom, 8)
                    } else {
                        VStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
                                
                                TextField("Filter logs...", text: viewStore.binding(get: \ .filter, send: { .filter($0) }))
                                    .padding()
                                    .background(Color.white)
                                    .focused($isTextFieldFocused)
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            isTextFieldFocused = true
                                        }
                                    }
                                
                                Button(action: {
                                    viewStore.send(.filter(""))
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color(AdColorPalette.Primary.accent.color))
                                }
                            }
                            .padding(.horizontal, 8)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(AdColorPalette.Background.placeholder.color))
                            }
                            
                            Spacer()
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: viewStore.logMessages) { newValue in
                    if let lastIndex = viewStore.logMessages.indices.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastIndex)
                        }
                    }
                }
                .onAppear {
                    logsSubscription = TestAppLogController.shared.logger.logs
                        .receive(on: DispatchQueue.main)
                        .sink { logMessages in
                            viewStore.send(.receiveLog(logMessages))
                        }
                    
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                        logsHeight = 80
                    }
                    
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                        isSearching = false
                        isTextFieldFocused = false
                        logsHeight = previousHeight
                    }
                }
                .onDisappear {
                    logsSubscription?.cancel()
                    logsSubscription = nil
                    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
                }
                .animation(.easeInOut, value: isSearching)
            }
        }
    }
    
    private func nearestHeight(to height: CGFloat) -> CGFloat {
        let snapPoints = [collapsedHeight, halfHeight, fullHeight]
        return snapPoints.min(by: { abs($0 - height) < abs($1 - height) }) ?? collapsedHeight
    }
}
