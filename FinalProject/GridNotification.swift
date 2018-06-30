//
//  Notifications.swift
//  FinalProject
//
//  Created by Jared Faucher on 7/30/17.
//  Copyright © 2017 Harvard University. All rights reserved.
//

import Foundation

struct GridNotification {
    static func setupListener(name: String, observer: Any, selector: Selector) {
        let name = Notification.Name(name)
        NotificationCenter.default.addObserver(observer,
                                               selector: selector,
                                               name: name,
                                               object: nil)
    }
    static func cancelListener(observer: Any) {
        NotificationCenter.default.removeObserver(observer)
    }
}
