//
//  AdTagFeature.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 04/06/2024.
//

internal import ComposableArchitecture
import SwiftUI

enum TagDisplayMode {
    case fill, stroke
}
protocol AdTag: Equatable {
    var displayMode: TagDisplayMode { get }
    var name: String { get }
    var description: String { get }
    var color: Color { get }
    var textColor: Color { get }
}

public enum OguryAdTag: String, AdTag {
    case ogury, max, dtFairbid, unityLevelPlay, direct, bypass, waterfall, headerBidding, oguryTestMode, rtbTestMode, beta
    
    enum DisplayMode {
        case fill, stroke
    }
    var displayMode: TagDisplayMode {
        switch self {
            default: return .fill
        }
    }
    
    public var name: String {
        switch self {
            case .ogury: return "Ogury"
            case .max: return "Max"
            case .dtFairbid: return "Digital Turbine Fairbid"
            case .direct: return "Direct"
            case .bypass: return "No adapter"
            case .waterfall: return "Waterfall"
            case .headerBidding: return "HB"
            case .unityLevelPlay: return "Unity LevelPlay"
            case .oguryTestMode: return "Ogury Test Mode"
            case .rtbTestMode: return "RTB Test Mode"
            case .beta: return "Beta"
        }
    }
    public var description: String {
        switch self {
            case .ogury: return "Ogury"
            case .max: return "AppLovin Max"
            case .dtFairbid: return "Fyber"
            case .unityLevelPlay: return "Unity LevelPlay"
            case .direct: return "Direct integration"
            case .bypass: return "The mediation's SDK is bypassed when loading the ad. In header bidding mediation case, the test app directly calls the ms-bidder endpoint of the mediation to retrieve an ad"
            case .waterfall: return "Waterfall auction integration"
            case .headerBidding: return "Header bidding integration"
            case .oguryTestMode: return "Add _test to the ad unit"
            case .rtbTestMode: return "Add test=1 to bid request"
            case .beta: return "This feature is still in development"
        }
    }
    
    internal var color: Color {
        switch self {
            case .ogury: return Color(#colorLiteral(red: 0.07843137255, green: 0.2862745098, blue: 0.462745098, alpha: 1))
            case .max: return Color(#colorLiteral(red: 0.337254902, green: 0.01176470588, blue: 0.6666666667, alpha: 1))
            case .dtFairbid: return Color(#colorLiteral(red: 0.8274509804, green: 0.09803921569, blue: 0.2509803922, alpha: 1))
            case .unityLevelPlay: return Color(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1))
            case .direct: return Color(#colorLiteral(red: 0.5176470588, green: 0.8549019608, blue: 1, alpha: 1))
            case .bypass:  return Color(#colorLiteral(red: 0, green: 0.3490196078, blue: 0.3490196078, alpha: 1))
            case .waterfall: return Color(#colorLiteral(red: 0, green: 0.5913378596, blue: 1, alpha: 1))
            case .headerBidding: return Color(#colorLiteral(red: 0.7647058824, green: 0.9176470588, blue: 0.462745098, alpha: 1))
            case .oguryTestMode: return Color(#colorLiteral(red: 0.8326988816, green: 0.2894239128, blue: 0.3478675783, alpha: 1))
            case .rtbTestMode: return Color(#colorLiteral(red: 0.8326988816, green: 0.2894239128, blue: 0.3478675783, alpha: 1))
            case .beta: return Color(#colorLiteral(red: 0.09803921569, green: 0.2588235294, blue: 0.4196078431, alpha: 1))
        }
    }
    
    internal var textColor: Color {
        switch self {
            case .direct, .headerBidding: return .black
            default: return .white
        }
    }
}

struct AdTagFeature: Reducer {
    struct State: Equatable {
        static func == (lhs: AdTagFeature.State, rhs: AdTagFeature.State) -> Bool { lhs.flip == rhs.flip }
        @PresentationState var alert: AlertState<Action.Alert>?
        let tag: OguryAdTag
        var flip = true
        var size: AdTagList.TagSize
    }
    
    enum Action {
        case tagTouched
        case alert(PresentationAction<Alert>)
        enum Alert {}
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .tagTouched:
                    state.alert = AlertState(title: {
                        TextState(state.tag.name)
                    }, message: { [state] in
                        TextState(state.tag.description)
                    })
                    state.flip.toggle()
                    return .none
                    
                case .alert:
                    return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
}
