//
//  VCExtras.swift
//  Rideable
//
//  Created by Donny Blaine on 3/3/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//
import Foundation
import UIKit

extension UITableViewController{
    //MARK: - Display Error

    
    //MARK: - Activity Indicator
    // Show activity indicator. Credit to raywenderlich.com
    func activityIndicatorShowing(showing: Bool, view: UIView, tableView: UITableView) {
        if showing {
            let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
            let container: UIView = UIView()
            let loadingView: UIView = UIView()
            container.tag = 1
            container.frame = view.frame
            container.center = view.center
            container.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.3)
            loadingView.frame = CGRect(x:0, y:0, width:80, height:80)
            loadingView.center = view.center
            loadingView.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.7)
            loadingView.clipsToBounds = true
            loadingView.layer.cornerRadius = 10
            activityIndicator.frame = CGRect(x:0, y:0, width:40, height:40)
            activityIndicator.center = CGPoint(x: (loadingView.frame.size.width / 2), y: (loadingView.frame.size.height / 2))
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            activityIndicator.color = UIColor(red: 0.12, green: 0.78, blue: 0.91, alpha: 1.0)
            DispatchQueue.main.async {
                loadingView.addSubview(activityIndicator)
                container.addSubview(loadingView)
                //view.addSubview(loadingView)
                view.addSubview(container)
                tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
                activityIndicator.startAnimating()
                tableView.isScrollEnabled = false
            }
        } else {
            tableView.isScrollEnabled = true
            let subViews = view.subviews
            for subview in subViews{
                if subview.tag == 1 {
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    //Displays messages in a certain style/color depending upon the message
    func displayMessage(message: String, view: UIView){
        switch message {
        case Constants.Notifications.Messages.alreadyUpdated, Constants.Notifications.Messages.settingsUpdated:
            view.showToast(message, position: .bottom, popTime: 1.0, dismissOnTap: false)
            break;
        default:
            if WeatherInfo.sharedInstance.messageShown == false {
                view.showToast(message, tag: nil, position: .bottom, popTime: 2.5, dismissOnTap: true, bgColor: UIColor.red, textColor: UIColor.white, font: nil)
                WeatherInfo.sharedInstance.messageShown = true
            }
            break;
        }
    }
    
    //Converts Military time to standard time
    func militaryToCivilTime(time: Int)->String{
        let time = Int(time)
        if time == 0 {
            return "12 pm"
        }
        if time < 13 {
            return "\(time) am"
        }else{
            let civilTime = time-12
            return "\(civilTime) pm"
        }
    }
    
    //Since the FRC has no way of sorting the one-many entities(hours), we must do so here before displaying
    func sortHourArray(day: Day?) -> [Hour]?{
        //return nil if the day or hours are nil
        guard let day = day, var hours = day.hour?.allObjects as? [Hour] else{
            return nil
        }
        
        hours = hours.sorted(by: { (a, b) -> Bool in  //sort the hours and return result
            
            if a.id < b.id {
                return true
            }else{
                return false
            }
        })
        return hours
    }
    
    
    //Sets background image depending upon the weather condition
    func setBackgroundImage(day: String, tableView: UITableView, condition: String?) {
        var imageView: UIImageView
        var image: UIImage
        
        guard let condition = condition else{
            image = UIImage(named: "\(day)")!
            imageView = UIImageView(image: image)
            return
        }
        
        switch condition {
        case "chancerain", "chancetstorms", "rain", "tstorms":
            image = UIImage(named: "\(day)Rain")!
            imageView = UIImageView(image: image)
            imageView.layer.opacity = 0.85
            break
        case "chanceflurries", "chancesnow", "flurries", "sleet", "snow":
            image = UIImage(named: "\(day)Snow")!
            imageView = UIImageView(image: image)
            imageView.layer.opacity = 0.80
            break
        default:
            image = UIImage(named: "\(day)")!
            imageView = UIImageView(image: image)
            imageView.layer.opacity = day == Constants.TypeOfDay.TODAY ? 0.95 : 0.8
            break
        }
        
        tableView.backgroundView = imageView
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.black
    }
}

//MARK: - Network Status
import SystemConfiguration

protocol Utilities {
}

extension NSObject:Utilities{
    
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    var currentReachabilityStatus: ReachabilityStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
}
