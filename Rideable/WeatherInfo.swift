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
    private var timeOfLastDataUpdate: Date?
    public var messageShown = false
    public var shouldAllowUpdateOverride = false
    
    //Runtime variables that change frequently so I just decided to store them in the singleton. Unsure if I should store in UserDefaults later.
    public var loadTodayGauge = true
    public var loadTomorrowGauge = true
    
    func updateWeatherInfo(){
        timeOfLastDataUpdate = UserDefaults.standard.object(forKey: "date") as! Date?
        guard isWeatherDataExpired() else {
            self.sendRefreshNotification(withMessage: "Weather up to date")
            return
        }
        requestWeatherDataUpdate()
    }
    
    private func requestWeatherDataUpdate(){
        isCurrentlyLoading = true
        WeatherClient.sharedInstance.sendRequest { (success, error) in
            guard success == true else{
                self.sendRefreshNotification(withMessage: error!)
                return
            }
            self.setNewFetchDate()
            self.sendRefreshNotification(withMessage: nil)
        }
    }
    
    private func setNewFetchDate(){
        UserDefaults.standard.set(true, forKey: Constants.Defaults.firstTimeDataLoad)
        UserDefaults.standard.set(Date(), forKey: "date")
    }
    
    private func sendRefreshNotification(withMessage message: String?){
        self.isCurrentlyLoading = false
        NotificationCenter.default.post(name: Constants.Notifications.REFRESH_NOTIFICATION, object: message)
    }
    
    private func isWeatherDataExpired() -> Bool {
        guard !hasSpecialOverrideConditions() else {return true}
        return isWeatherOutOfDate()
    }
    
    private func hasSpecialOverrideConditions() -> Bool {
        guard timeOfLastDataUpdate != nil else {return true}
        guard shouldAllowUpdateOverride == false else {
            shouldAllowUpdateOverride = false
            return true
        }
        return false
    }
    
    private func isWeatherOutOfDate() -> Bool {
        let unitsPassedSinceLastUpdate = Calendar.current.dateComponents([.minute], from: (timeOfLastDataUpdate)! as Date, to: Date()).minute ?? Constants.Data.weatherUpdateIntervalInMinutes
        return unitsPassedSinceLastUpdate >= Constants.Data.weatherUpdateIntervalInMinutes
    }
    

    // MARK: Singleton
    static let sharedInstance = WeatherInfo()
    private override init() {}
}

