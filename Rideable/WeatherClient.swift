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
    
    typealias completionHandler = (_ success : Bool, _ error: String?) -> Void
    
    func sendRequest(completionHandler: @escaping completionHandler) {
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = Constants.Data.timeoutInSeconds
        
        // Add Headers
        let headers = [
            "Cookie":"DT=1487473989:26720:ip-10-226-237-178; Prefs=FAVS:1|WXSN:1|PWSOBS:1|WPHO:1|PHOT:1|RADC:0|RADALL:0|HIST0:NULL|GIFT:1|PHOTOTHUMBS:50|EXPFCT:1|",
            ]

        // Fetch Request 
        manager.request("https://api.wunderground.com/api/\(IgnoreConstants.apiKey)/conditions/hourly/forecast/forecast10day/q/Tyler,Tx.json", method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        guard let data = response.data else{
                            completionHandler(false, "Error Retreiving Weather Data")
                            return
                        }
                        
                        let json = JSON(data: data)
                        self.parseJson(json: json, completionHandler: { (success, error) in
                            guard success == true else{
                                completionHandler(false, error)
                                return
                            }
                            completionHandler(true, nil)
                        })
                    }
                }
                else {
                    debugPrint("HTTP Request failed: \(response.result.error)")
                    completionHandler(false, response.result.error?.localizedDescription)
                }
        }
    }
    
    // MARK: Singleton
    static let sharedInstance = WeatherClient()
    private init() {} //To prevent others from using the default '()' initializer
}


