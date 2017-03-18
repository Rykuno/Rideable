//
//  HourCell.swift
//  Rideable
//
//  Created by Donny Blaine on 3/12/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import UIKit
import GaugeKit

class HourCell: UITableViewCell {

    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var condition: UILabel!
    @IBOutlet weak var wind: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var gauge: Gauge!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var precipChance: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var view: UIView!
    
    var isObserving = false;
    class var expandedHeight: CGFloat { get { return 140 } }
    class var defaultHeight: CGFloat  { get { return 70  } }
    
    func initializeHourCell(hour: Hour?){
        guard let hour = hour else{
            return
        }
        
        let calcScore = calculateScore(hour: hour)
        score.text = "\(calcScore)"
        condition.text = hour.condition
        wind.text = "\(hour.windSpeed) \(hour.windDir!)"
        humidity.text = "\(hour.humidity)%"
        time.text = militaryToCivilTime(time: Int(hour.time))
        temp.text = "\(hour.temp)\(Constants.Symbols.degree)"
        precipChance.text = calculatePrecip(precip: hour.precip)
        icon.image = UIImage(named: hour.icon!)
        gauge.rate = CGFloat(calcScore)
        
        print(Float(calcScore)/100.00)
        gauge.startColor = mixGreenAndRed(score: calcScore)
    }
    
    func mixGreenAndRed(score: Int) -> UIColor {
        let x = (Float(score)/100.00)/3
        return UIColor(hue:CGFloat(x), saturation:1.0, brightness:1.0, alpha:1.0)
    }
    
 
    private func calculateScore(hour: Hour) -> Int {
        let defaults = UserDefaults.standard
        let tempWeight = defaults.double(forKey: Constants.Defaults.tempWeight)/100
        let humidityWeight = defaults.double(forKey: Constants.Defaults.humidityWeight)/100
        let precipWeight = defaults.double(forKey: Constants.Defaults.precipWeight)/100
        let windWeight = defaults.double(forKey: Constants.Defaults.windWeight)/100
        
        let tempDiff = abs(defaults.double(forKey: Constants.Defaults.temp)-Double(hour.temp))
        let humidityDiff = abs(defaults.double(forKey: Constants.Defaults.humidity)-Double(hour.humidity))
        let precipDiff = abs(defaults.double(forKey: Constants.Defaults.precip)-Double(hour.precip))
        let windDiff = abs(defaults.double(forKey: Constants.Defaults.wind)-Double(hour.windSpeed))
        
        return Int(100 - (tempWeight * tempDiff) - (humidityWeight * humidityDiff) - (precipWeight * precipDiff) - (windWeight * windDiff))
        
    }
    
    func checkHeight() {
        view.isHidden = (frame.size.height < HourCell.expandedHeight)
    }
    
    func watchFrameChanges() {
        if !isObserving {
            addObserver(self, forKeyPath: "frame", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.initial], context: nil)
            isObserving = true;
        }
    }
    
    func ignoreFrameChanges() {
        if isObserving {
            removeObserver(self, forKeyPath: "frame")
            isObserving = false;
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame" {
            checkHeight()
        }
    }
    
    private func calculatePrecip(precip: Int16) -> String{
        let modPrecip = 10 * Int(round(Double(precip) / 10))
            if modPrecip == 0{
                precipChance.isHidden = true
                return "\(modPrecip)%"
            }else{
                precipChance.isHidden = false
                return "\(modPrecip)%"
        }
    
    }
    
    private func militaryToCivilTime(time: Int)->String{
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

}
