//
//  WeatherParser.swift
//  Rideable
//
//  Created by Donny Blaine on 3/3/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

extension WeatherInfo {
    
    
    public func parseJson(json: JSON) {
        let stack = WeatherClient.sharedInstance.stack
        parseToday(json: json, stack: stack)
    }
    
    public func parseToday(json: JSON, stack: CoreDataStack) {
            stack.performAndWaitBackgroundBatchOperation { (moc) in
                let request: NSFetchRequest<Day> = Day.fetchRequest()
                request.predicate = NSPredicate(format: "type == %@", Constants.TypeOfDay.TODAY)
                
                do{
                    if var day = try moc.fetch(request).first {
                         day = TodayWeather.init(json: json).editOrCreateDay(day, moc)
                    }else{
                        var day = Day(context: moc)
                        day = self.editOrCreateDay(day, moc)
                    }
                }catch{
                    
                }
            }
            stack.save()
    }
}
