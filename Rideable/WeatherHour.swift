//
//  WeatherHour.swift
//  Rideable
//
//  Created by Donny Blaine on 2/27/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

struct WeatherHour {
    enum Day: Int {
        case Tomorrow
        case Today
    }
    private var json: JSON!
    
    init(json: JSON) {
        self.json = json
    }
    
    func getCurrentHours(moc: NSManagedObjectContext, day: Day) -> [Hour]{
        var hours = [Hour]()
        
        /**
         If Today, parse hours the next 12 hours(0-12),
         If Tomorrow, parse the next 12 hours starting tomorrow at 7am(24-currentHour+6)
        **/
        let start = (day == Day.Today) ?  0 : 24-Calendar.current.component(.hour, from: Date())+6

        for index in start...start+11 {
            let hour = Hour(context: moc)
            let currentHour = json["hourly_forecast"][index]
            hour.humidity = Int16(currentHour["humidity"].intValue)
            hour.precip = Int16(currentHour["pop"].intValue)
            hour.temp = Int16(currentHour["temp"]["english"].intValue)
            hour.windSpeed = Int16(currentHour["wspd"]["english"].intValue)
            hour.condition = currentHour["condition"].stringValue
            hour.icon = currentHour["icon"].stringValue
            hour.windDir = currentHour["wdir"]["dir"].stringValue
            hour.time = Int16(currentHour["FCTTIME"]["hour"].intValue)
            hour.id = Int16(index)
            hours.append(hour)
        }
        return hours
    }
    
    func modifyCurrentHours(hour: Hour) -> Hour {
            let currentHour = json["hourly_forecast"][Int(hour.id)]
            hour.humidity = Int16(currentHour["humidity"].intValue)
            hour.precip = Int16(currentHour["pop"].intValue)
            hour.temp = Int16(currentHour["temp"]["english"].intValue)
            hour.windSpeed = Int16(currentHour["wspd"]["english"].intValue)
            hour.condition = currentHour["condition"].stringValue
            hour.icon = currentHour["icon"].stringValue
            hour.windDir = currentHour["wdir"]["dir"].stringValue
            hour.time = Int16(currentHour["FCTTIME"]["hour"].intValue)
        return hour
    }
}
