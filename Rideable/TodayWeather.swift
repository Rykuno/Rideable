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
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    var json: JSON!
    init(json: JSON) {
        self.json = json
    }
    
    private func saveToCoreData(){
        stack.performAndWaitBackgroundBatchOperation { (moc) in
            let request: NSFetchRequest<Day> = Day.fetchRequest()
            request.predicate = NSPredicate(format: "type == %@", Constants.TypeOfDay.TODAY)
            
            do{
                if var day = try moc.fetch(request).first {
                    day = self.editOrCreateDay(day, moc)
                }else{
                    var day = Day(context: moc)
                    day = self.editOrCreateDay(day, moc)
                }
            }catch{
                
            }
        }
        stack.save() 
    }
    
    public func editOrCreateDay(_ day: Day, _ moc: NSManagedObjectContext) -> Day {
        let currentObservation = json["current_observation"]
        day.summary = currentObservation["weather"].stringValue
        day.currentTemp = Int16(currentObservation["temp_f"].intValue)
        day.time = currentObservation["observation_time"].stringValue
        day.wind = Int16(Int(currentObservation["wind_mph"].doubleValue))
        day.humidity = currentObservation["relative_humidity"].stringValue
        day.location = currentObservation["display_location"]["full"].stringValue
        day.icon = currentObservation["icon"].stringValue
        let currentForecast = json["forecast"]["simpleforecast"]["forecastday"][0]
        day.precipitation = Int16(currentForecast["pop"].intValue)
        day.tempHigh = Int16(currentForecast["high"]["fahrenheit"].intValue)
        day.tempLow = Int16(currentForecast["low"]["fahrenheit"].intValue)
        day.created = Date() as NSDate
        day.type = Constants.TypeOfDay.TODAY
        
        if (day.hour?.allObjects.isEmpty)!{
            print("creating hours")
            let hours = WeatherHour(json: json).getCurrentHours(moc: moc, day: .Today)
            for hour in hours {
                day.addToHour(hour)
            }
        }else{
            print("modifying hours")
            for var hour in day.hour?.allObjects as! [Hour]{
                hour = WeatherHour(json: json).modifyCurrentHours(hour: hour)
            }
        }
        return day
    }
}
