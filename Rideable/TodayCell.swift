//
//  TodayCell.swift
//  Rideable
//
//  Created by Donny Blaine on 3/8/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import UIKit
import GaugeKit

class TodayCell: UITableViewCell {
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var daySummary: UILabel!
    @IBOutlet weak var gauge: Gauge!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var condition: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var tempLow: UILabel!
    @IBOutlet weak var tempHigh: UILabel!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var feelsLike: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var wind: UILabel!
    @IBOutlet weak var precip: UILabel!
    
    private let defaults = UserDefaults.standard
    private let isMetric: Bool = UserDefaults.standard.bool(forKey: Constants.Defaults.metricUnits)
    
    
    func initializeDayCell(day: Day?, shouldAnimate: Bool, isTodayCell: Bool){
        guard let day = day else{
            return
        }
        
        score.text = "\(calculateScore(day: day))"
        precip.text = "\(day.precipitation)%"
        humidity.text = day.humidity
        wind.text = "\(calculateWind(windInMph: day.wind, intValue: false))"
        condition.text = day.summary
        icon.image = UIImage(named: day.icon!)
        tempLow.text = "\(Constants.Symbols.downArrow)\(calculateTemperature(temp: day.tempLow))"
        tempHigh.text = "\(Constants.Symbols.upArrow)\(calculateTemperature(temp:day.tempHigh))"
        currentTemp.text = "\(calculateTemperature(temp: day.currentTemp))\(Constants.Symbols.degree)"
        daySummary.text = parseSentence(sentence: day.daySummary)
        daySummary.backgroundColor = UIColor.gray.withAlphaComponent(0.25)
        daySummary.numberOfLines = 2
        feelsLike.text = "Feels like \(day.feelsLike)"
        updatedAtLabel.text = day.time
        daySummary.adjustsFontSizeToFitWidth = true
        
        if isTodayCell{
            tempLow.text = "\(Constants.Symbols.downArrow)\(calculateTemperature(temp: day.tempLow))"
            tempHigh.text = "\(Constants.Symbols.upArrow)\(calculateTemperature(temp:day.tempHigh))"
            currentTemp.text = "\(calculateTemperature(temp: day.currentTemp))\(Constants.Symbols.degree)"
        }else{
            currentTemp.text = "\(Constants.Symbols.downArrow)\(calculateTemperature(temp: day.tempLow))\(Constants.Symbols.degree)\(Constants.Symbols.upArrow)\(calculateTemperature(temp:day.tempHigh))\(Constants.Symbols.degree)"
            currentTemp.font = currentTemp.font.withSize(35)
            currentTemp.textAlignment = .left
            tempHigh.isHidden = true
            tempLow.isHidden = true
            feelsLike.isHidden = true
        }
        
        if shouldAnimate == false {
            gauge.rate = CGFloat(calculateScore(day: day))
        }else{
            gauge.animateRate(TimeInterval(1), newValue: CGFloat(calculateScore(day: day))) { (success) in}
        }
    }
    
    private func calculateScore(day: Day) -> Int {
        let tempWeight = defaults.double(forKey: Constants.Defaults.tempWeight)/100
        let humidityWeight = defaults.double(forKey: Constants.Defaults.humidityWeight)/100
        let precipWeight = defaults.double(forKey: Constants.Defaults.precipWeight)/100
        let windWeight = defaults.double(forKey: Constants.Defaults.windWeight)/100
        
        //regex to remove any non digit characters from the humidity
        let humidityInt = Int((day.humidity?.replacingOccurrences(of: "\\D", with: "", options: .regularExpression, range: (day.humidity?.startIndex)!..<(day.humidity?.endIndex)!))!)
        let tempDiff = abs(defaults.double(forKey: Constants.Defaults.temp)-Double(calculateTemperature(temp: day.currentTemp)))
        let humidityDiff = abs(defaults.double(forKey: Constants.Defaults.humidity)-Double(humidityInt!))
        let precipDiff = abs(defaults.double(forKey: Constants.Defaults.precip)-Double(day.precipitation))
        let windDiff = abs(defaults.double(forKey: Constants.Defaults.wind)-Double(calculateWind(windInMph: day.wind, intValue: true))!)
        
        return Int(100 - (tempWeight * tempDiff) - (humidityWeight * humidityDiff) - (precipWeight * precipDiff) - (windWeight * windDiff))
    }
    
    // Set The temperature to either Fahrenheit/Celsius depending on the users pref.
    private func calculateTemperature(temp: Int16) -> Int{
        if isMetric {
            let metricTemp = (Int(temp)-32) * 5/9
            return metricTemp
        }else{
            return (Int(temp))
        }
    }
    
    //Calculate Wind to either mph/kph
    private func calculateWind(windInMph: Int16, intValue: Bool) -> String{
        if intValue {
            if isMetric {
                let metricWind = Int((Double(windInMph)) * 1.6)
                return "\(metricWind)"
            }else{
                return "\(windInMph)"
            }
        }else{
            if isMetric {
                let metricWind = Int((Double(windInMph)) * 1.6)
                return "\(metricWind) kph"
            }else{
                return "\(windInMph) mph"
            }
        }
    }
    
    /*
     The daily summaries can get pretty long, so here we substring the first
     two sentences and return those.
     */
    private func parseSentence(sentence: String?) -> String{
        guard let sentence = sentence else{
            return ""
        }
        
        var subStringArray:[String] = []
        var outputSentence: String = ""
        
        //substring by sentence and add to subStringArray
        sentence.enumerateSubstrings(in: sentence.startIndex ..< sentence.endIndex, options: .bySentences) { (substring, range, rangeIndex, inoutBool) in
            subStringArray.append(substring!)
        }
        
        //If there are more than two sentences, append the first two and return it
        //else just return the original sentence.
        if subStringArray.count > 2 {
            for index in 0...1 {
                outputSentence.append(subStringArray[index])
            }
            return outputSentence
        }else{
            return sentence
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
