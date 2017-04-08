//
//  TomorrowWeather.swift
//  Rideable
//
//  Created by Donny Blaine on 3/3/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

struct TomorrowWeather {
    
    private var json: JSON!
    
    init(_ json: JSON) {
        self.json = json
    }
    
    //Parse tomorrow json
    public func parse(_ day: Day, _ moc: NSManagedObjectContext) -> Day {
        let currentObservation = json["current_observation"]
        let currentForecast = json["forecast"]["simpleforecast"]["forecastday"][1]
        day.summary = currentForecast["conditions"].stringValue
        day.precipitation = Int16(currentForecast["pop"].intValue)
        day.tempHigh = Int16(currentForecast["high"]["fahrenheit"].intValue)
        day.tempLow = Int16(currentForecast["low"]["fahrenheit"].intValue)
        day.location = currentObservation["display_location"]["full"].stringValue
        day.time = currentObservation["observation_time"].stringValue
        day.icon = currentForecast["icon"].stringValue
        day.humidity = "\(currentForecast["avehumidity"].intValue)%"
        day.wind = Int16(currentForecast["avewind"]["mph"].intValue)
        day.created = Date() as NSDate
        day.type = Constants.TypeOfDay.TOMORROW
        day.daySummary = json["forecast"]["txt_forecast"]["forecastday"][2]["fcttext"].stringValue

        if (day.hour?.allObjects.isEmpty)!{
            let hours = WeatherHour(json: json).getCurrentHours(moc: moc, day: .Tomorrow)
            for hour in hours {
                day.addToHour(hour)
            }
        }else{
            var hours = day.hour?.allObjects as! [Hour]
            hours = WeatherHour(json: json).modifyHours(hours: hours, moc: moc, day: .Tomorrow)
        }
        return day
    }
}
