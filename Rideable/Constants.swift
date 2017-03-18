//
//  Constants.swift
//  Rideable
//
//  Created by Donny Blaine on 2/28/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import Foundation
import UIKit

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
        static let weatherUpdateIntervalInMinutes = 5
        static let timeoutInSeconds = TimeInterval(30)
    }
    
    struct CellReuseIdentifiers {
        static let day = "day"
        static let hour = "hour"
    }
    
    struct Defaults {
        static let firstLaunch = "isAppAlreadyLaunchedOnce"
        static let standardUnit = "measurementDefault"
        static let standardTime = "timeDefault"
        static let temp = "temp"
        static let humidity = "humidity"
        static let precip = "precipitation"
        static let wind = "wind"
        static let tempWeight = "tempWeight"
        static let humidityWeight = "humidityWeight"
        static let precipWeight = "precipWeight"
        static let windWeight = "windWeight"
    }
    
    struct Colors {
    }
    // MARK: Menu Constants
    struct Menu {
        struct Icons{
            private static let todayWeather = UIImage(named: "todayIcon")
            private static let tomorrowWeather = UIImage(named: "tomorrowIcon")
            private static let weeklyWeather = UIImage(named: "10DayIcon")
            private static let settingsIcon = UIImage(named: "toolsIcon")
            private static let aboutIcon = UIImage(named: "aboutIcon")
            private static let facebookIcon = UIImage(named: "facebookIcon")
            private static let twitterIcon = UIImage(named: "twitterIcon")
            private static let githubIcon = UIImage(named: "githubIcon")
            
            static let weatherIcons = [todayWeather, tomorrowWeather, weeklyWeather]
            static let optionsIcons = [settingsIcon, aboutIcon]
            static let shareIcons = [facebookIcon, twitterIcon, githubIcon]
            
        }
        
        struct Items {
            static let weatherItems = ["Today", "Tomorrow", "10 Day"]
            static let optionItems = ["Settings", "About"]
            static let shareItems = ["Facebook", "Twitter", "GitHub"]
        }
        
        struct Sections {
            static let sections = ["Weather", "Options", "Share"]
        }
    }
    
    struct Symbols {
        static let upArrow = "↑"
        static let downArrow = "↓"
        static let degree = "°"
    }
}
