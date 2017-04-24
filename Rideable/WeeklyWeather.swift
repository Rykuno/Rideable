//
//  WeekWeather.swift
//  Rideable
//
//  Created by Donny Blaine on 3/3/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

struct WeeklyWeather {
    
    private var json: JSON!
    
    init(_ json: JSON) {
        self.json = json
    }
    
    //Parse weekly json
    public func parse(_ weekDays: [Week]?, _ moc: NSManagedObjectContext )-> [Week] {
        if weekDays == nil {
            var weekArray = [Week]()
            for index in 0...9 {
                let week = Week(context: moc)
                let forecast = json["forecast"]["simpleforecast"]["forecastday"][index]
                let txtForecast = json["forecast"]["txt_forecast"]["forecastday"][index]
                week.weekday = forecast["date"]["weekday"].stringValue
                week.tempHigh = Int16(forecast["high"]["fahrenheit"].intValue)
                week.tempLow = Int16(forecast["low"]["fahrenheit"].intValue)
                week.condition = forecast["conditions"].stringValue
                week.detailCondition = txtForecast["fcttext"].stringValue
                week.icon = forecast["icon"].stringValue
                week.precip = Int16(forecast["pop"].intValue) 
                week.windSpeed = Int16(forecast["avewind"]["mph"].intValue)
                week.windDirection = forecast["avewind"]["dir"].stringValue
                week.windDegrees = Int16(forecast["avewind"]["degrees"].intValue)
                week.humidity = Int16(forecast["avehumidity"].intValue)
                week.id = Int16(index)

                weekArray.append(week)
            }
            return weekArray
        }else{
            for week in weekDays! {
                let forecast = json["forecast"]["simpleforecast"]["forecastday"][Int(week.id)]
                let txtForecast = json["forecast"]["txt_forecast"]["forecastday"][Int(week.id)]
                week.weekday = forecast["date"]["weekday"].stringValue
                week.tempHigh = Int16(forecast["high"]["fahrenheit"].intValue)
                week.tempLow = Int16(forecast["low"]["fahrenheit"].intValue)
                week.condition = forecast["conditions"].stringValue
                week.icon = forecast["icon"].stringValue
                week.precip = Int16(forecast["pop"].intValue)
                week.windSpeed = Int16(forecast["avewind"]["mph"].intValue)
                week.windDirection = forecast["avewind"]["dir"].stringValue
                week.windDegrees = Int16(forecast["avewind"]["degrees"].intValue)
                week.humidity = Int16(forecast["avehumidity"].intValue)
                week.detailCondition = txtForecast["fcttext"].stringValue
            }
            return weekDays!
        }
    }
}
