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
        if let settingsURL = Bundle.main.url(forResource: "Root", withExtension: "plist", subdirectory: "Settings.bundle"),
           let settingsRootDict = NSDictionary(contentsOf: settingsURL),
           let prefSpecifiers = settingsRootDict["PreferenceSpecifiers"] as? [NSDictionary],
           let keysAndValues = prefSpecifiers.map({ d in (d["Key"], d["DefaultValue"]) }) as? [(String, Any)] {
            UserDefaults.standard.register(defaults: Dictionary(uniqueKeysWithValues: keysAndValues))
        }
    }
    
    static func getApiUrl() -> String {
        let url : String? = UserDefaults.standard.string(forKey: SettingsBundleKeys.ApiUrlKey)
        return url != nil ? url! : "http://localhost:3000"
    }
}
