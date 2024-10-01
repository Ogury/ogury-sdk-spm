//
//  ThumbnailOptionFeature.swift
//  AdCard
//
//  Created by Jerome TONNELIER on 21/07/2023.
//

import ComposableArchitecture
import OguryAds

struct ThumbnailDisplayOptions: Equatable {
    var xOffset = "100"
    var yOffset = "100"
    var width = "180"
    var height = "180"
    var showOptions = false
    var thumbnailPosition: ThumbnailPosition = .topleft
}

enum ThumbnailPosition: Hashable, CaseIterable, Identifiable {
    var id: Self { self }
    case topleft, topright, bottomleft, bottomright, position, `default`
    
    var imageName: String {
        switch self {
            case .topleft: return "rectangle.portrait.topleft.inset.filled"
            case .topright: return "rectangle.portrait.topright.inset.filled"
            case .bottomleft: return "rectangle.portrait.bottomleft.inset.filled"
            case .bottomright: return "rectangle.portrait.bottomright.inset.filled"
            case .position: return "plus.rectangle.portrait"
            case .default: return "rectangle.portrait"
        }
    }
    var displayName: String {
        switch self {
            case .topleft: return "corner - topleft"
            case .topright: return "corner - topright"
            case .bottomleft: return "corner - bottomleft"
            case .bottomright: return "corner - bottomright"
            case .position: return "position"
            case .default: return "default"
        }
    }
    var sectionName: String {
        switch self {
            case .topleft, .topright, .bottomleft, .bottomright: return "Offset"
            case .position: return "Position"
            case .default: return "Not applicable"
        }
    }
    var sectionDisabled: Bool {
        switch self {
            case .default: return true
            default: return false
        }
    }
    var corner: OguryRectCorner? {
        switch self {
        case .topleft: return .topLeft
        case .topright: return .bottomLeft
        case .bottomleft: return .bottomLeft
        case .bottomright: return .bottomRight
        case .position: return .none
        case .default: return .none
        }
    }
}

struct ThumbnailOptionFeature: Reducer {
    struct State: Equatable {
        @BindingState var options: ThumbnailDisplayOptions
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                case .binding: return .none
            }
        }
    }
}
