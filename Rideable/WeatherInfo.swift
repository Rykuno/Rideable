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
    private var lastUpdateTime: Date?
    private var allowUpdateOverride = false
    /*
     Updates Weather Info if the current info is expired
     */
    func updateWeatherInfo(){
        //Set lastUpdateTime
        if weatherInfoExpired() {
            lastUpdateTime = UserDefaults.standard.object(forKey: "date") as! Date?
            isCurrentlyLoading = true
            WeatherClient.sharedInstance.sendRequest { (success, error) in
                guard success == true else{
                    self.isCurrentlyLoading = false
                    print("ERROR = \(error)")
                    NotificationCenter.default.post(name: Constants.Notifications.REFRESH_NOTIFICATION, object: error)
                    return
                } 
                
                UserDefaults.standard.set(Date(), forKey: "date")
                self.isCurrentlyLoading = false
                NotificationCenter.default.post(name: Constants.Notifications.REFRESH_NOTIFICATION, object: nil)
            }
        }else{
            let updateMsg = "Weather up to date"
            NotificationCenter.default.post(name: Constants.Notifications.REFRESH_NOTIFICATION, object: updateMsg)
        }
    }
    
    public func setUpdateOverrideStatus(shouldOverride: Bool) {
        allowUpdateOverride = shouldOverride
    }
    
    //Checks to see if the weather info has expired.
    private func weatherInfoExpired() -> Bool {

        /*
         if the lastUpdateTime is nil, then
         its probably a first time startup so
         return true.
         */
        guard lastUpdateTime != nil else {
            return true
        }
        
        guard allowUpdateOverride == false else {
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
            print("Weather out of date")
            return true
        }else{
            print("Weather up to date")
            return false
        }
    }
    
    // MARK: Singleton
    static let sharedInstance = WeatherInfo()
    private override init() {}
}
 
