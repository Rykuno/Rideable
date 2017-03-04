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
    
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    var json: JSON!
    
    init(json: JSON) {
        self.json = json
        saveToCoreData()
    }
    
    private func saveToCoreData(){
        stack.performAndWaitBackgroundBatchOperation { (moc) in
            let request: NSFetchRequest<Week> = Week.fetchRequest()

            do{
                var results = try moc.fetch(request)
                
                if results.isEmpty{
                    results = self.editOrCreateDay(nil, moc)
                }else{
                    results = self.editOrCreateDay(results, moc)
                }
            }catch{
                
            }
        }
        stack.save()
    }
    
    private func editOrCreateDay(_ weekDays: [Week]?, _ moc: NSManagedObjectContext )-> [Week] {
        if weekDays == nil {
            var weekArray = [Week]()
            for index in 0...9 {
                let week = Week(context: moc)
                let forecast = json["forecast"]["simpleforecast"]["forecastday"][index]
                week.weekday = forecast["date"]["weekday"].stringValue
                week.tempHigh = Int16(forecast["high"]["fahrenheit"].intValue)
                week.tempLow = Int16(forecast["low"]["fahrenheit"].intValue)
                week.condition = forecast["conditions"].stringValue
                week.icon = forecast["icon"].stringValue
                week.precip = Int16(forecast["pop"].intValue)
                week.windSpeed = Int16(forecast["avewind"]["mph"].intValue)
                week.windDirection = forecast["avewind"]["dir"].stringValue
                week.humidity = Int16(forecast["avehumidity"].intValue)
                week.id = Int16(index)
                weekArray.append(week)
            }
            return weekArray
        }else{
            for week in weekDays! {
                let forecast = json["forecast"]["simpleforecast"]["forecastday"][Int(week.id)]
                week.weekday = forecast["date"]["weekday"].stringValue
                week.tempHigh = Int16(forecast["high"]["fahrenheit"].intValue)
                week.tempLow = Int16(forecast["low"]["fahrenheit"].intValue)
                week.condition = forecast["conditions"].stringValue
                week.icon = forecast["icon"].stringValue
                week.precip = Int16(forecast["pop"].intValue)
                week.windSpeed = Int16(forecast["avewind"]["mph"].intValue)
                week.windDirection = forecast["avewind"]["dir"].stringValue
                week.humidity = Int16(forecast["avehumidity"].intValue)
            }
            return weekDays!
        }
    }
}
