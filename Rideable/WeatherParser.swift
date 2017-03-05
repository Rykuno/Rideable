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

extension WeatherClient {
    
    // MARK: Parsing
    // Here we parse the Today, Tomorrow, and 10Day forecasts.
    func parseJson(json: JSON, completionHandler: @escaping completionHandler){
        let stack = (UIApplication.shared.delegate as! AppDelegate).stack
        
        //Parse Todays Weather
        parseToday(json, stack) { (success, error) in
            guard success == true else{
                completionHandler(false, error)
                return
            }
        }
        
        //Parse Tomorrows Weather
        parseTomorrow(json, stack) { (success, error) in
            guard success == true else{
                completionHandler(false, error)
                return
            }
        }
        
        //Parse the Week's Weather
        parseWeek(json, stack) { (success, error) in
            guard success == true else{
                completionHandler(false, error)
                return
            }
        }
        
        //Save after all changes have been made and return
        stack.save()
        completionHandler(true, nil)
        
    }
    
    /* Perform fetch on Today Entity. If the entity exists just modify its contents,
     else create a new entity then save to parent context so normal saving
     can work 
     
     NOTE: Today and Tomorrow use the same entity due to similarities and are
     differentiated through the type attribute. */
    private func parseToday(_ json: JSON, _ stack: CoreDataStack, completionHandler: @escaping completionHandler) {
            stack.performAndWaitBackgroundBatchOperation { (moc) in
                let request: NSFetchRequest<Day> = Day.fetchRequest()
                request.predicate = NSPredicate(format: "type == %@", Constants.TypeOfDay.TODAY)
                
                do{
                    if var day = try moc.fetch(request).first {
                         day = TodayWeather.init(json).parse(day, moc)
                    }else{
                        var day = Day(context: moc)
                        day = TodayWeather.init(json).parse(day, moc)
                    }
                }catch{
                    completionHandler(false, error.localizedDescription)
                }
            }
            completionHandler(true, nil)
    }
    
    /* Perform fetch on Tomorrow Entity. If the entity exists just modify its contents, else create a new entity then save to parent context so normal saving
        can work 
     
     NOTE: Today and Tomorrow use the same entity due to similarities and are
     differentiated through the type attribute. */
    private func parseTomorrow(_ json: JSON, _ stack: CoreDataStack, completionHandler: @escaping completionHandler){
        stack.performAndWaitBackgroundBatchOperation { (moc) in
            let request: NSFetchRequest<Day> = Day.fetchRequest()
            request.predicate = NSPredicate(format: "type == %@", Constants.TypeOfDay.TOMORROW)
            
            do{
                if var day = try moc.fetch(request).first {
                    day = TomorrowWeather.init(json).parse(day, moc)
                }else{
                    var day = Day(context: moc)
                    day = TomorrowWeather.init(json).parse(day, moc)
                }
            }catch{
                completionHandler(false, error.localizedDescription)
            }
        }
        completionHandler(true, nil)
    }
    
    /* Perform fetch on Tomorrow Entity. If the entity exists just modify its contents, else create a new entity then save to parent context so normal saving
     can work
     
     NOTE: Week is its own entity without a relation to hours. */
    private func parseWeek(_ json: JSON, _ stack: CoreDataStack, completionHandler: @escaping completionHandler){
        stack.performAndWaitBackgroundBatchOperation { (moc) in
            let request: NSFetchRequest<Week> = Week.fetchRequest()
            
            do{
                var results = try moc.fetch(request)
                
                if results.isEmpty{
                    results = WeeklyWeather(json).parse(nil, moc)
                }else{
                    results = WeeklyWeather(json).parse(results, moc)
                }
            }catch{
               completionHandler(false, error.localizedDescription)
            }
        }
        completionHandler(true, nil)
    }
}
