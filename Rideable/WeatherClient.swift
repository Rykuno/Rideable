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
import SwiftLocation
import CoreLocation

class WeatherClient {
    typealias completionHandler = (_ success : Bool, _ error: String?) -> Void
    
    func sendRequest(completionHandler: @escaping completionHandler) {
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = Constants.Data.timeoutInSeconds
        
        // Add Headers
        let headers = [
            "Cookie":"DT=1487473989:26720:ip-10-226-237-178; Prefs=FAVS:1|WXSN:1|PWSOBS:1|WPHO:1|PHOT:1|RADC:0|RADALL:0|HIST0:NULL|GIFT:1|PHOTOTHUMBS:50|EXPFCT:1|",
            ]
        
        getLocation { (location, error) in
            guard error == nil else{
                completionHandler(false, error)
                return
            }
            
            //send request with location
            manager.request("https://api.wunderground.com/api/\(IgnoreConstants.apiKey)/conditions/hourly/forecast/forecast10day/q/\(location!).json", method: .get, headers: headers)
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
    }
    
    private func getLocation(completionHandler: @escaping (_ location: String?, _ error: String?) -> Void) {
        
        //If the user has not accepted or has declined the auth, provide a default and
        //resort to user input in the settings for location
        guard CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .notDetermined else {
            if UserDefaults.standard.string(forKey: Constants.Defaults.location) == nil {
                completionHandler("90001", nil)
                return
            }else{
                completionHandler(UserDefaults.standard.string(forKey: Constants.Defaults.location), nil)
                return
            }
        }
        
        guard UserDefaults.standard.string(forKey: Constants.Defaults.location) == nil else {
            completionHandler(UserDefaults.standard.string(forKey: Constants.Defaults.location), nil)
            return
        }
        
        Location.getLocation(accuracy: .city, frequency: .oneShot, success: { (request, location) -> (Void) in
            let coords = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            print(coords)
            completionHandler(coords, nil)
        }) { (request, location, error) -> (Void) in
            completionHandler(nil, error.localizedDescription)
            
        }
    }
    
    // MARK: Singleton
    static let sharedInstance = WeatherClient()
    private init() {} //To prevent others from using the default '()' initializer
}

