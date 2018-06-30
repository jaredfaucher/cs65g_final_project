//
//  UserDefaultsWrapper.swift
//  FinalProject
//
//  Created by Jared Faucher on 7/28/17.
//  Copyright © 2017 Harvard University. All rights reserved.
//

import Foundation

class UDWrapper {
    /// A static method to retrieve a string with a known key from UserDefaults
    class func getLastSavedConfig(key: String = Const.UserDefaults.lastSavedConfiguration) -> String? {
        return UserDefaults.standard.string(forKey:key)
    }
    
    /// A static method to save a string value for a known key in UserDefaults
    class func setLastSavedConfig(key: String = Const.UserDefaults.lastSavedConfiguration, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
}

extension Const {
    struct UserDefaults {
        /// The known key
        static let lastSavedConfiguration = "lastSavedConfiguration"
    }
}
