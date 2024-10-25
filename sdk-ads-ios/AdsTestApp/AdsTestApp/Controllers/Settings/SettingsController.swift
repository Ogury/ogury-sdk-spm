//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

import Foundation
import UserDefault

struct SettingsController {
    @UserDefault("enableAdUnitEditing")
    var enableAdUnitEditing: Bool = true
    
    @UserDefault("showCampaignId")
    var showCampaignId: Bool = true
    
    @UserDefault("showCreativeId")  
    var showCreativeId: Bool = false
    
    @UserDefault("showSpecificOptions")
    var showSpecificOptions: Bool = false
    
    @UserDefault("showDspFields")
    var showDspFields: Bool = false
    
    @UserDefault("bulkModeEnabled")
    var bulkModeEnabled: Bool = false
    
    @UserDefault("startSDKWithApplication")
    var startSDKWithApplication: Bool = false
    
    @UserDefault("numberOfSdkStart")
    var numberOfSdkStart: Int = 1
    
    @UserDefault("showTestMode")
    var showTestMode: Bool = true
    
    @UserDefault("enableFeedbacks")
    var enableFeedbacks: Bool = true
   
    @UserDefault("usOptout")
    var usOptout: Bool = false
   
    @UserDefault("usOptoutPartner")
    var usOptoutPartner: Bool = false
}
