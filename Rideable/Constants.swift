//
//  Constants.swift
//  Rideable
//
//  Created by Donny Blaine on 2/28/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import Foundation

struct Constants {
    struct Notifications{
        static let REFRESH_NOTIFICATION = NSNotification.Name("RefreshNotification")
    }
    
    struct TypeOfDay {
        static let TODAY = "today"
        static let TOMORROW = "tomorrow"
        static let WEEK = "week"
    }
    
    struct Measurement {
    }
    
    struct Data {
        static let weatherUpdateIntervalInMinutes = 0
    }
    
    struct CellReuseIdentifiers {
        static let day = "day"
        static let hour = "hour"
    }
}
