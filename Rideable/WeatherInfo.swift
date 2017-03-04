//
//  WeatherInfo.swift
//  Rideable
//
//  Created by Donny Blaine on 2/27/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//
import Foundation
import UIKit


class WeatherInfo: NSObject {
    
    var isCurrentlyLoading = false
    
    func updateWeatherInfo(){
        isCurrentlyLoading = true
        WeatherClient.sharedInstance.sendRequest { (success, error) in
            guard success == true else{
                self.isCurrentlyLoading = false
                return
            }
        
        self.isCurrentlyLoading = false
        NotificationCenter.default.post(name: Constants.Notifications.REFRESH_NOTIFICATION, object: nil)
        }
    }
    
    // MARK: Singleton
    static let sharedInstance = WeatherInfo()
    private override init() {} //To prevent others from using the default '()' initializer
}
