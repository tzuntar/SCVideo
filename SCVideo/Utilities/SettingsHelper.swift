//
//  SettingsHelper.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 3/21/23.
//

import Foundation

class SettingsHelper {    
    private struct SettingsBundleKeys {
        static let ApiUrlKey = "api_url"
    }
    
    /**
     Registers the default values from Settings.bundle
     */
    static func registerSettingsBundle() {
        if let settingsBundlePath = Bundle.main.path(forResource: "Settings", ofType: "bundle"),
           let settings = NSDictionary(contentsOfFile: "\(settingsBundlePath)/Root.plist"),
           let preferences = settings.object(forKey: "PreferenceSpecifiers") as? [NSDictionary] {
            var defaultsToRegister = [String: Any]()
            for preference in preferences {
                if let key = preference.object(forKey: "Key") as? String {
                    defaultsToRegister[key] = preference.object(forKey: "DefaultValue")
                }
            }
            UserDefaults.standard.register(defaults: defaultsToRegister)
        }
    }
    
    static func getApiUrl() -> String {
        let url : String? = UserDefaults.standard.string(forKey: SettingsBundleKeys.ApiUrlKey)
        let defaultUrl = Bundle.main.object(forInfoDictionaryKey: "DEFAULT_SERVER_IP") as? String
        return url != nil ? url! : (defaultUrl != nil ? defaultUrl! : "http://localhost:3000")
    }
}
