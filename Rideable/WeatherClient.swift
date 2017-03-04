//
//  WeatherClient.swift
//  Rideable
//
//  Created by Donny Blaine on 2/27/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class WeatherClient {
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    func sendRequest(completionHandler: @escaping (_ success : Bool, _ error: String?) -> Void) {
        // Add Headers
        let headers = [
            "Cookie":"DT=1487473989:26720:ip-10-226-237-178; Prefs=FAVS:1|WXSN:1|PWSOBS:1|WPHO:1|PHOT:1|RADC:0|RADALL:0|HIST0:NULL|GIFT:1|PHOTOTHUMBS:50|EXPFCT:1|",
            ]
        
        // Fetch Request
        Alamofire.request("https://api.wunderground.com/api/43ee969456775837/conditions/hourly/forecast/forecast10day/q/Tyler,Tx.json", method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        guard let data = response.data else{
                            completionHandler(false, "Error Retreiving Weather Data")
                            return
                        }
                        
                        let json = JSON(data: data)
                        self.parseJson(json: json, completionHandler: { (success) in
                            if success{
                                completionHandler(true, nil)
                            }else{
                                completionHandler(false, "Error loading data")
                            }
                        })
                    }
                }
                else {
                    debugPrint("HTTP Request failed: \(response.result.error)")
                    completionHandler(false, response.result.error?.localizedDescription)
                }
        }
    }
    
    // MARK: Parsing
    // Here we parse the Today, Tomorrow, and 10Day forecasts.
    private func parseJson(json: JSON, completionHandler: @escaping (_ success: Bool) -> Void){
        TodayWeather(json: json)
        TomorrowWeather(json: json)
        WeeklyWeather(json: json)
        completionHandler(true)
     
    }
    
    
    // MARK: Singleton
    static let sharedInstance = WeatherClient()
    private init() {} //To prevent others from using the default '()' initializer
}


