//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

import Foundation
import UserDefault
import AdsCardLibrary

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
    
    @UserDefault("killWebviewMode")
    var killWebviewMode: KillWebviewMode = .none
    
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
   
    @UserDefault("showLogsSheet")
    var showLogsSheet: Bool = false
   
    @UserDefault("importMethod")
    var importMethod: ImportMethod = SettingsController.qaMode ? .rawText : .file
    
    var appPermissions: AppPermissions {
        get {
            guard let permissionsData: Data = UserDefaults.standard.value(forKey: AppPermissions.userDefaultKey) as? Data,
                  let permissions = try? JSONDecoder().decode(AppPermissions.self, from: permissionsData) else {
                return AppPermissions()
            }
            return permissions
        }
        
        set {
            // save AppPermissions only if there was no permission before
            if UserDefaults.standard.value(forKey: AppPermissions.userDefaultKey) == nil,
               let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.setValue(data, forKey: AppPermissions.userDefaultKey)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    static let qaMode: Bool = {
#if QA_MODE
        return true
#else
        return false
#endif
    }()
    
    static func loadPreferences() {
        // if there are some data stored in UserDefaults, then we don't handle start configuration files
        guard (try? AdsStorableContainer.loadSavedData()) == nil else { return }
        
        var file: AdsStorableContainer?
        // load custom settings if provided
        // 1. we check if the file Custom.settings file is populated
        if let settings = try? AdsStorableContainer.loadJsonFromFile(named: "Custom", extension: "settings") {
            file = settings
        }
        
        // otherwise, check if QA mode is activated
#if QA_MODE
        if file == nil,
           let settings = try? AdsStorableContainer.loadJsonFromFile(named: "Default-qa", extension: "settings") {
            file = settings
        }
#endif
        // if no file has been loaded, load the default file
        if file == nil,
           let settings = try? AdsStorableContainer.loadJsonFromFile(named: "Default", extension: "settings") {
            file = settings
        }
        
        file?.save()
    }
    
    private static func loadFile(named fileName: String, extension fileExt: String?) -> AdsStorableContainer? {
        try? AdsStorableContainer.loadJsonFromFile(named: fileName, extension: fileExt)
    }
}

extension KillWebviewMode: @retroactive DefaultsValueConvertible {
    
}
