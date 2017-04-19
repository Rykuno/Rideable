//
//  WeatherInfo.swift
//  Rideable
//
//  Created by Donny Blaine on 2/27/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//
import Foundation
import UIKit
import SwiftLocation

class WeatherInfo: NSObject {
    
    private(set) var isCurrentlyLoading = false
    public var allowUpdateOverride = false
    private var lastUpdateTime: Date?
    public var messageShown = false
    
    //Runtime variables that change frequently so I just decided to store them in the singleton. Unsure if I should store in UserDefaults later.
    public var loadTodayGauge = true
    public var loadTomorrowGauge = true
    
    /*
     Updates Weather Info if the current info is expired
     */
    func updateWeatherInfo(){
        //Set lastUpdateTime
        lastUpdateTime = UserDefaults.standard.object(forKey: "date") as! Date?
        
        if weatherInfoExpired() {
            isCurrentlyLoading = true
            WeatherClient.sharedInstance.sendRequest { (success, error) in
                guard success == true else{
                    self.isCurrentlyLoading = false
                    NotificationCenter.default.post(name: Constants.Notifications.REFRESH_NOTIFICATION, object: error)
                    return
                }
                print("settings date")
                UserDefaults.standard.set(Date(), forKey: "date")
                self.isCurrentlyLoading = false
                NotificationCenter.default.post(name: Constants.Notifications.REFRESH_NOTIFICATION, object: nil)
            }
        }else{
            let updateMsg = "Weather up to date"
            NotificationCenter.default.post(name: Constants.Notifications.REFRESH_NOTIFICATION, object: updateMsg)
        }
    }
    
    //Checks to see if the weather info has expired.
    private func weatherInfoExpired() -> Bool {
        
        /*
         if the lastUpdateTime is nil, then
         its probably a first time startup so
         return true.
         */
        guard lastUpdateTime != nil else {
            print("no last update time")
            return true
        }
        
        guard allowUpdateOverride == false else {
            print("overriding")
            allowUpdateOverride = false
            return true
        }
        
        /*
         If lastUpdateTime exists, check if last fetch info has expired.
         NOTE: According to Wunderground, the API is updated every 15 minutes.
         https://www.wunderground.com/about/data
         */
        let unitsPassedSinceLastUpdate = Calendar.current.dateComponents([.minute], from: (lastUpdateTime)! as Date, to: Date()).minute ?? Constants.Data.weatherUpdateIntervalInMinutes
        if unitsPassedSinceLastUpdate >= Constants.Data.weatherUpdateIntervalInMinutes {
            return true
        }else{
            return false
        }
    }
    
    // MARK: Singleton
    static let sharedInstance = WeatherInfo()
    private override init() {}
}

