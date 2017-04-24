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
    
    //MARK: - Variables
    @IBOutlet weak var precipIcon: UIImageView!
    @IBOutlet weak var wind: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var precipDetail: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var condition: UILabel!
    @IBOutlet weak var gauge: Gauge!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var precipChance: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var windDirectionIcon: UIImageView!
    
    var isObserving = false;
    private let defaults = UserDefaults.standard
    private let isMetric: Bool = UserDefaults.standard.bool(forKey: Constants.Defaults.metricUnits)
    private var hour: Hour!

    class var expandedHeight: CGFloat { get { return 130 } }
    class var defaultHeight: CGFloat  { get { return 70  } }
    
    //MARK: - Cell Initialization
    //Initializes the cell with the hour from the VC
    func initializeHourCell(hour: Hour?){
        guard let hour = hour else{return}
        self.hour = hour
        initializeScore()
        initializeCondition()
        initializeWind()
        initializeHumidity()
        initializeTime()
        initializeTemperature()
        initializePrecipitation()
        initializeIcon()
        initializeGauge()
    }
   
    //MARK : - Initialize Outlets
    private func initializeScore() {
        let calcScore = calculateScore(hour: hour)
        score.text = "\(calcScore)"
        score.adjustsFontSizeToFitWidth = true
    }
    
    private func initializeCondition() {
        condition.text = hour.condition
    }
    
    private func initializeWind() {
        wind.text = "\(calculateWind(windInMph: hour.windSpeed)) \(getCurrentMeasurement())"
        windDirectionIcon.transform = CGAffineTransform(rotationAngle: CGFloat(Double(hour.windDegrees) * Double.pi)/180)
        wind.adjustsFontSizeToFitWidth = true
    }
    
    private func initializeHumidity() {
        humidity.text = "\(hour.humidity)%"
        humidity.adjustsFontSizeToFitWidth = true
    }
    
    private func initializeTime(){
        time.text = calculateTime(time: Int(hour.time))
    }
    
    private func initializeTemperature(){
        temp.text = "\(calculateTemperature(temp: hour.temp))\(Constants.Symbols.degree)"
    }
    
    private func initializePrecipitation() {
        let calculatedPrecip = calculatePrecip(precip: hour.precip)
        precipChance.text = calculatedPrecip
        precipDetail.text = calculatedPrecip
        precipDetail.adjustsFontSizeToFitWidth = true
    }
    
    private func initializeIcon() {
        if let image = UIImage(named: hour.icon!) {
            icon.image = image
        }else{
            icon.image = UIImage(named: "unknown")
        }
    }
    
    private func initializeGauge() {
        let calcScore = calculateScore(hour: hour)
        gauge.rate = CGFloat(calcScore)
        gauge.startColor = mixGreenAndRed(score: calcScore)
    }
    
    
    //MARK: - Expanding Cell Functions
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
    
    //MARK: - Computing Functions
    //Calculates precipitation on cell row.
    //NOTE: If we hide the views, it breaks the UI for some reason so fixing via opacity.
    private func calculatePrecip(precip: Int16) -> String{
        let modPrecip = 10 * Int(round(Double(precip) / 10))
        if modPrecip == 0{
            //precipChance.isHidden = true
            //precipIcon.isHidden = true
            precipChance.layer.opacity = 0.0
            precipIcon.layer.opacity = 0.0
            return "\(modPrecip)%"
        }else{
            //precipChance.isHidden = false
            //precipIcon.isHidden = false
            precipChance.layer.opacity = 1.0
            precipIcon.layer.opacity = 1.0
            return "\(modPrecip)%"
        }
    }
    
    //Calculate time depending on users preferences
    private func calculateTime(time: Int) -> String {
        if  defaults.bool(forKey: Constants.Defaults.standardTime) == true {
            return militaryToCivilTime(time: time)
        }else{
            return "\(time)"
        }
    }
    
    // Set The temperature to either Fahrenheit/Celsius depending on the users pref.
    private func calculateTemperature(temp: Int16) -> String{
        if isMetric {
            let metricTemp = (Int(temp)-32) * 5/9
            return "\(metricTemp)"
        }else{
            return "\(temp)"
        }
    }
    
    private func getCurrentMeasurement()-> String {
        return isMetric ? "kph" : "mph"
    }
    
    //Calculates wind kpm/mph
    private func calculateWind(windInMph: Int16) -> String{
        if isMetric {
            let metricWind = Int((Double(windInMph)) * 1.6)
            return "\(metricWind)"
        }else{
            return "\(windInMph)"
        }
    }
    
    //Converts military to civilian time.
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
    
    //Depending on the score, calculate the color of the gauge
    private func mixGreenAndRed(score: Int) -> UIColor {
        let x = (Float(score)/100.00)/3
        return UIColor(hue:CGFloat(x), saturation:0.7, brightness:1.0, alpha:1.0)
    }
    
    // Depending on the users wieght and ride preference, calculate the score
    // NOTE : Maybe change this to a better alg later.
    private func calculateScore(hour: Hour) -> Int {
        let tempWeight = defaults.double(forKey: Constants.Defaults.tempWeight)/100 * 2
        let humidityWeight = defaults.double(forKey: Constants.Defaults.humidityWeight)/100 * 2
        let precipWeight = defaults.double(forKey: Constants.Defaults.precipWeight)/100 * 2
        let windWeight = defaults.double(forKey: Constants.Defaults.windWeight)/100 * 2
        let tempDiff = abs(defaults.double(forKey: Constants.Defaults.temp)-Double(hour.temp))
        let humidityDiff = abs(defaults.double(forKey: Constants.Defaults.humidity)-Double(hour.humidity))
        let precipDiff = abs(defaults.double(forKey: Constants.Defaults.precip)-Double(hour.precip))
        let windDiff = abs(defaults.double(forKey: Constants.Defaults.wind)-Double(hour.windSpeed))
        let calculatedScore = Int(100 - (tempWeight * tempDiff) - (humidityWeight * humidityDiff) - (precipWeight * precipDiff) - (windWeight * windDiff))
        return calculatedScore<0 ? 0 : calculatedScore
    }
    
}
