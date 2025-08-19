//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import UIKit
internal import ComposableArchitecture

@Reducer
struct WhatsNewFeature {
    @ObservableState
    struct State: Equatable {
        var markdownString =
"""
  ## Try MarkdownUI

  **MarkdownUI** is a native Markdown renderer for SwiftUI
  compatible with the
  [GitHub Flavored Markdown Spec](https://github.github.com/gfm/).

  ## Status
  Use `git status` to list all new or modified files
  that haven't yet been committed.

  ### Quotes
  You can quote text with a `>`.

  > Outside of a dog, a book is man's best friend. Inside of a
  > dog it's too dark to read.

  – Groucho Marx

"""
    }
    
    enum Action: Equatable  {}
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
