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
        
        struct Messages {
            static let alreadyUpdated = "Weather up to date"
            static let settingsUpdated = "Settings Updated!"
        }
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
        static let metricUnits = "measurementDefault"
        static let standardTime = "timeDefault"
        static let temp = "temp"
        static let humidity = "humidity"
        static let precip = "precipitation"
        static let wind = "wind"
        static let tempWeight = "tempWeight"
        static let humidityWeight = "humidityWeight"
        static let precipWeight = "precipWeight"
        static let windWeight = "windWeight"
        static let location = "location"
        static let displayLocation = "displayLocation"
        static let userPrefersLocationServices = "UserPrefersLocationServices"
        static let firstTimeDataLoad = "firstTimeDataLoad"
    }
    
    // MARK: Menu Constants
    struct Menu {
        struct Icons{
            private static let todayWeather = UIImage(named: "todayIcon")
            private static let tomorrowWeather = UIImage(named: "tomorrowIcon")
            private static let weeklyWeather = UIImage(named: "10DayIcon")
            private static let settingsIcon = UIImage(named: "toolsIcon")
            private static let facebookIcon = UIImage(named: "facebookIcon")
            private static let twitterIcon = UIImage(named: "twitterIcon")

            static let weatherIcons = [todayWeather, tomorrowWeather, weeklyWeather]
            static let optionsIcons = [settingsIcon]
            static let shareIcons = [facebookIcon, twitterIcon]
            
        }
        
        struct Items {
            static let weatherItems = ["Today", "Tomorrow", "10 Day"]
            static let optionItems = ["Settings"]
            static let shareItems = ["Facebook", "Twitter"]
        }
        
        struct Sections { 
            static let sections = ["Weather", "Options", "Share"]
        }
    }
    
    struct backgroundImages{
        static let today = UIImage(named: "today")
        static let tomorrow = UIImage(named: "tomorrow")
        static let week = UIImage(named: "week")
        static let todayRain = UIImage(named: "todayRain")
        static let todaySnow = UIImage(named: "todaySnow")
        static let tomorrowSnow = UIImage(named: "tomorrowSnow")
        static let tomorrowRain = UIImage(named: "tomorrowRain")
        
    }
    
    struct Symbols {
        static let upArrow = "↑"
        static let downArrow = "↓"
        static let degree = "°"
    }
}
