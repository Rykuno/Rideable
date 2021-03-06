//
//  AppDelegate.swift
//  Rideable
//
//  Created by Donny Blaine on 2/27/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Rideable")!
     
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        isAppAlreadyLaunchedOnce()
        WeatherInfo.sharedInstance.updateWeatherInfo()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        stack.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if !UserDefaults.standard.bool(forKey: "locationalServicesEnabled") {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                UserDefaults.standard.set(true, forKey: "locationalServicesEnabled")
                UserDefaults.standard.set(true, forKey: Constants.Defaults.userPrefersLocationServices)
                
                break
            case .denied: 
                UserDefaults.standard.set("Dallas,Texas", forKey: Constants.Defaults.location)
                UserDefaults.standard.set("Dallas,Texas", forKey: Constants.Defaults.displayLocation)
                UserDefaults.standard.set(false, forKey: Constants.Defaults.userPrefersLocationServices)
                WeatherInfo.sharedInstance.updateWeatherInfo()
                break
            default: break
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        stack.save()
    }
    
    func isAppAlreadyLaunchedOnce(){
        let defaults = UserDefaults.standard

        if let isAppAlreadyLaunchedOnce = defaults.string(forKey: Constants.Defaults.firstLaunch){
            print("App already launched : \(isAppAlreadyLaunchedOnce)")
        }else{
            defaults.set(true, forKey: Constants.Defaults.standardTime)
            defaults.set(false, forKey: Constants.Defaults.metricUnits)
            defaults.set(true, forKey: Constants.Defaults.firstLaunch)
            defaults.set(false, forKey: "firstDataLoad")
            defaults.set(70.0, forKey: Constants.Defaults.temp)
            defaults.set(30.0, forKey: Constants.Defaults.humidity)
            defaults.set(0.0, forKey: Constants.Defaults.precip)
            defaults.set(10.0, forKey: Constants.Defaults.wind)
            defaults.set(30, forKey: Constants.Defaults.tempWeight)
            defaults.set(15, forKey: Constants.Defaults.humidityWeight)
            defaults.set(40, forKey: Constants.Defaults.precipWeight)
            defaults.set(15, forKey: Constants.Defaults.windWeight)
            defaults.set(false, forKey: "locationalServicesEnabled")
            print("App launched first time")
        }
    }
}
