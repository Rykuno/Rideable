//
//  TodayWeather.swift
//  Rideable
//
//  Created by Donny Blaine on 2/27/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

struct TodayWeather{
    
    private var json: JSON!
    
    init(_ json: JSON) {
        self.json = json
    }
     
    //Parse the json for Today
    public func parse(_ day: Day, _ moc: NSManagedObjectContext) -> Day {
        let currentObservation = json["current_observation"]
        day.summary = currentObservation["weather"].stringValue
        day.currentTemp = Int16(currentObservation["temp_f"].intValue)
        day.time = currentObservation["observation_time"].stringValue
        day.wind = Int16(Int(currentObservation["wind_mph"].doubleValue))
        print("TODAYS WIND SPEED IS : \(day.wind)") 
        day.windDirectionDegrees = Int16(Int(currentObservation["wind_degrees"].intValue))
        day.humidity = currentObservation["relative_humidity"].stringValue
        day.location = currentObservation["display_location"]["full"].stringValue
        day.icon = currentObservation["icon"].stringValue
        let currentForecast = json["forecast"]["simpleforecast"]["forecastday"][0]
        day.precipitation = Int16(currentForecast["pop"].intValue)
        day.tempHigh = Int16(currentForecast["high"]["fahrenheit"].intValue)
        day.tempLow = Int16(currentForecast["low"]["fahrenheit"].intValue)
        day.created = Date() as NSDate
        day.type = Constants.TypeOfDay.TODAY
        day.daySummary = json["forecast"]["txt_forecast"]["forecastday"][0]["fcttext"].stringValue
        day.feelsLike = Int16(currentObservation["feelslike_f"].intValue)
        
        if (day.hour?.allObjects.isEmpty)!{
            let hours = WeatherHour(json: json).getCurrentHours(moc: moc, day: .Today)
            for hour in hours {
                day.addToHour(hour)
            }
        }else{
            var hours = day.hour?.allObjects as! [Hour]
            hours = WeatherHour(json: json).modifyHours(hours: hours, moc: moc, day: .Today)
        }
            return day
    }
}
