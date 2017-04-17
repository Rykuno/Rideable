//
//  WeekCell.swift
//  Rideable
//
//  Created by Donny Blaine on 4/6/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import UIKit
import CoreData
import GaugeKit

class WeekCell: UITableViewCell {
    
    @IBOutlet weak var weekday: UILabel!
    @IBOutlet weak var condition: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var gauge: Gauge!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var daySummary: UILabel!
    @IBOutlet weak var scoreDetail: UILabel!
    @IBOutlet weak var rain: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var wind: UILabel!
    
    private let defaults = UserDefaults.standard
    private let isMetric: Bool = UserDefaults.standard.bool(forKey: Constants.Defaults.metricUnits)
    var isObserving = false;
    
    class var expandedHeight: CGFloat { get { return 150 } }
    class var defaultHeight: CGFloat  { get { return 70  } }
    
    
    func initializeWeekCell(week: Week){
        //Score
        let score = calculateScore(week: week)
        gauge.rate = CGFloat(score)
        gauge.startColor = mixGreenAndRed(score: score)
        scoreDetail.text = "\(score)"
        
        //Weekday
        weekday.text = week.weekday
        
        //Condition
        let wordList =  week.condition?.components(separatedBy: .punctuationCharacters).joined().components(separatedBy: " ").filter{!$0.isEmpty}
        if (wordList?.count)! > 2 {
            if let word = wordList?[3] {
                condition.text = word
            }
        }else{
            condition.text = week.condition
        }
        condition.adjustsFontSizeToFitWidth = true
        
        //Icon
        icon.image = UIImage(named: week.icon!)
        
        //Temperature
        let avgTemp = (week.tempLow + week.tempHigh)/2
        temperature.text = "\(calculateTemperature(temp: avgTemp))\(Constants.Symbols.degree)"
        
        //Detail Summary
        daySummary.text = parseSentence(sentence: week.detailCondition)
        daySummary.adjustsFontSizeToFitWidth = true
        
        //Precipitation
        rain.text = "\(Int(week.precip))%"
        
        //Humidity
        humidity.text = "\(Int(week.humidity))%"
        
        //Wind
        wind.text = "\(week.windSpeed) \(week.windDirection!)"
    }
    
    //MARK: - Expanding Cell Functions
    
    func checkHeight() {
        view.isHidden = (frame.size.height < WeekCell.expandedHeight)
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
    //Calculate Score depending on user's weight/preferences
    private func calculateScore(week: Week) -> Int {
        let tempWeight = defaults.double(forKey: Constants.Defaults.tempWeight)/100 * 1.5
        let humidityWeight = defaults.double(forKey: Constants.Defaults.humidityWeight)/100 * 1.5
        let precipWeight = defaults.double(forKey: Constants.Defaults.precipWeight)/100 * 1.5
        let windWeight = defaults.double(forKey: Constants.Defaults.windWeight)/100 * 1.5
        
        let avgHighLowTemp = Int16((week.tempHigh + week.tempLow)/2)
        let tempDiff = abs(defaults.double(forKey: Constants.Defaults.temp)-Double(calculateTemperature(temp: avgHighLowTemp)))
        let humidityDiff = abs(defaults.double(forKey: Constants.Defaults.humidity)-Double(week.humidity))
        let precipDiff = abs(defaults.double(forKey: Constants.Defaults.precip)-Double(week.precip))
        let windDiff = abs(defaults.double(forKey: Constants.Defaults.wind)-Double(calculateWind(windInMph: week.windSpeed, intValue: true))!)
        
        return Int(100 - (tempWeight * tempDiff) - (humidityWeight * humidityDiff) - (precipWeight * precipDiff) - (windWeight * windDiff))
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
    
    //Set The temperature to either Fahrenheit/Celsius depending on the users pref.
    private func calculateTemperature(temp: Int16) -> Int{
        if isMetric {
            let metricTemp = (Int(temp)-32) * 5/9
            return metricTemp
        }else{
            return (Int(temp))
        }
    }
    
    //Depending on the score, calculate the color of the gauge
    private func mixGreenAndRed(score: Int) -> UIColor {
        let x = (Float(score)/100.00)/3
        return UIColor(hue:CGFloat(x), saturation:0.7, brightness:1.0, alpha:1.0)
    }
    
    
    //MARK: - Parsing Functions
    
    /*
     The daily summaries can get pretty long, so here we substring the first
     two sentences and return those.
     */
    private func parseSentence(sentence: String?) -> String{
        guard var sentence = sentence else{
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
            outputSentence = replaceUnitsInSentence(sentence: outputSentence)
            return outputSentence
        }else{
            sentence = replaceUnitsInSentence(sentence: sentence)
            return sentence
        }
    }
    
    //Replaces units from F to C within sentence so refreshing the weather is not needed when user swaps settings.
    private func replaceUnitsInSentence(sentence: String) -> String {
        //We only want to proceed if the user wants metric measurements since our default fetch is in standard
        if !isMetric {return sentence}
        
        let pattern = "([0-9]{1,3})F|([0-9]{1,3})"
        let arrayOfReplacements = sentence.matchingStrings(regex: pattern)
        
        //If there are no strings to match, lets just break
        guard arrayOfReplacements.count > 0 else{
            return sentence
        }
        //Loop over each word that needs replacing and replace with correct conversion
        var newSentence = sentence
        for replacement in arrayOfReplacements[0] {
            newSentence = newSentence.replacingOccurrences(of: replacement, with: calculateConversion(input: replacement))
        }
        return newSentence
    }
    
    //Converts strings that need converting from within sentence
    private func calculateConversion(input: String?) -> String {
        //If the input is nil, return
        guard let input = input else {
            return ""
        }
        //If the input contains F lets remove it and append C at then end of our conversion
        guard !input.contains("F") else{
            let number = Int(input.substring(to: input.index(before: input.endIndex)))
            if let number = number {
                return "\(calculateTemperature(temp: Int16(number)))C"
            }
            return ""
        }
        
        //!contain "F" & !null so lets just convert the string to an int, and calculate it.
        let number = Int(input)
        if let number = number {
            return "\(calculateTemperature(temp: Int16(number)))"
        }else{
            return ""
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


