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
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    var json: JSON!
    
    init(json: JSON) {
        self.json = json
        saveToCoreData()
    }
    
    private func saveToCoreData(){
        stack.performAndWaitBackgroundBatchOperation { (moc) in
            let request: NSFetchRequest<Day> = Day.fetchRequest()
            request.predicate = NSPredicate(format: "type == %@", Constants.TypeOfDay.TOMORROW)
            
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
    
    private func editOrCreateDay(_ day: Day, _ moc: NSManagedObjectContext) -> Day {
        let currentForecast = json["forecast"]["simpleforecast"]["forecastday"][1]
        day.summary = currentForecast["conditions"].stringValue
        day.precipitation = Int16(currentForecast["pop"].intValue)
        day.tempHigh = Int16(currentForecast["high"]["fahrenheit"].intValue)
        day.tempLow = Int16(currentForecast["low"]["fahrenheit"].intValue)
        day.icon = currentForecast["icon"].stringValue
        day.humidity = "\(currentForecast["avehumidity"].intValue)%"
        day.wind = Int16(currentForecast["avewind"]["mph"].intValue)
        day.created = Date() as NSDate
        day.type = Constants.TypeOfDay.TOMORROW
        
        if (day.hour?.allObjects.isEmpty)!{
            print("creating hours")
            let hours = WeatherHour(json: json).getCurrentHours(moc: moc, day: .Tomorrow)
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
