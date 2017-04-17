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
    //MARK: - Variables
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var daySummary: UILabel!
    @IBOutlet weak var gauge: Gauge!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var condition: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var tempLow: UILabel!
    @IBOutlet weak var tempHigh: UILabel!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var wind: UILabel!
    @IBOutlet weak var precip: UILabel!
    
    private let defaults = UserDefaults.standard
    private let isMetric: Bool = UserDefaults.standard.bool(forKey: Constants.Defaults.metricUnits)
    
    //MARK: - Cell Initialization
    //Initializes the cell with the day from the VC
    func initializeDayCell(day: Day?, shouldAnimate: Bool, isTodayCell: Bool){
        
        guard let day = day else{
            return
        }
        
        //Score
        let calculatedScore = calculateScore(day: day, isTodayCell: isTodayCell)
        score.text = "\(calculatedScore)"
        
        //Precipitation
        precip.text = "\(day.precipitation)%"
        
        //Humidity
        humidity.text = day.humidity
        
        //Wind
        wind.text = "\(calculateWind(windInMph: day.wind, intValue: false))"
        
        //Condition
        let wordList =  day.summary?.components(separatedBy: .punctuationCharacters).joined().components(separatedBy: " ").filter{!$0.isEmpty}
        if (wordList?.count)! > 2 {
            if let word = wordList?[2] {
                condition.text = word
            }
        }else{
            condition.text = day.summary
        }
        condition.adjustsFontSizeToFitWidth = true
        
        //Icon
        icon.image = UIImage(named: day.icon!)
        
        //Temperature
        tempLow.text = "\(Constants.Symbols.downArrow)\(calculateTemperature(temp: day.tempLow))"
        tempHigh.text = "\(Constants.Symbols.upArrow)\(calculateTemperature(temp:day.tempHigh))"
        currentTemp.text = "\(calculateTemperature(temp: day.currentTemp))\(Constants.Symbols.degree)"
        
        //Summary
        daySummary.text = parseSentence(sentence: day.daySummary)
        daySummary.backgroundColor = UIColor.gray.withAlphaComponent(0.25)
        daySummary.numberOfLines = 2
        daySummary.adjustsFontSizeToFitWidth = true
        
        //Location
        location.text = "\(day.location!)"
        location.adjustsFontSizeToFitWidth = true
        
        //UpdatedAt
        updatedAtLabel.text = "\(day.time!)"
        updatedAtLabel.adjustsFontSizeToFitWidth = true
        
        //Configure labels dependent upon the type of day
        if isTodayCell{ //If the cell is today
            tempLow.text = "\(Constants.Symbols.downArrow)\(calculateTemperature(temp: day.tempLow))"
            tempHigh.text = "\(Constants.Symbols.upArrow)\(calculateTemperature(temp:day.tempHigh))"
            currentTemp.text = "\(calculateTemperature(temp: day.currentTemp))\(Constants.Symbols.degree)"
            defaults.set(calculatedScore, forKey: "TodayScore")
        }else{ //If the cell is tomorrow lets replace current temperature with the high/low temp
            currentTemp.text = "\(Constants.Symbols.downArrow)\(calculateTemperature(temp: day.tempLow))\(Constants.Symbols.degree)\(Constants.Symbols.upArrow)\(calculateTemperature(temp:day.tempHigh))\(Constants.Symbols.degree)"
            currentTemp.font = currentTemp.font.withSize(35)
            currentTemp.textAlignment = .left
            currentTemp.adjustsFontSizeToFitWidth = true
            tempHigh.isHidden = true
            tempLow.isHidden = true
            location.isHidden = true
        }
        
        //Determines if the gauge view should animate or not
        if shouldAnimate == false {
            gauge.rate = CGFloat(calculateScore(day: day, isTodayCell: isTodayCell))
        }else{
            gauge.animateRate(TimeInterval(1), newValue: CGFloat(calculateScore(day: day, isTodayCell: isTodayCell))) { (success) in}
        }
    }
    
    //MARK: - Computing Functions
    //Calculate Score depending on user's weight/preferences
    private func calculateScore(day: Day, isTodayCell: Bool) -> Int {
        let tempWeight = defaults.double(forKey: Constants.Defaults.tempWeight)/100 * 1.5
        let humidityWeight = defaults.double(forKey: Constants.Defaults.humidityWeight)/100 * 1.5
        let precipWeight = defaults.double(forKey: Constants.Defaults.precipWeight)/100 * 1.5
        let windWeight = defaults.double(forKey: Constants.Defaults.windWeight)/100 * 1.5
        
        //regex to remove any non digit characters from the humidity
        let humidityInt = Int((day.humidity?.replacingOccurrences(of: "\\D", with: "", options: .regularExpression, range: (day.humidity?.startIndex)!..<(day.humidity?.endIndex)!))!)
        
        let tempDiff: Double!
        if isTodayCell{
            tempDiff = abs(defaults.double(forKey: Constants.Defaults.temp)-Double(calculateTemperature(temp: day.currentTemp)))
        }else{
            let avgHighLowTemp = Int16((day.tempHigh + day.tempLow)/2)
            tempDiff = abs(defaults.double(forKey: Constants.Defaults.temp)-Double(calculateTemperature(temp: avgHighLowTemp)))
        }
        
        let humidityDiff = abs(defaults.double(forKey: Constants.Defaults.humidity)-Double(humidityInt!))
        let precipDiff = abs(defaults.double(forKey: Constants.Defaults.precip)-Double(day.precipitation))
        let windDiff = abs(defaults.double(forKey: Constants.Defaults.wind)-Double(calculateWind(windInMph: day.wind, intValue: true))!)
        
        return Int(100 - (tempWeight * tempDiff) - (humidityWeight * humidityDiff) - (precipWeight * precipDiff) - (windWeight * windDiff))
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

extension String {
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map { result.rangeAt($0).location != NSNotFound
                ? nsString.substring(with: result.rangeAt($0))
                : ""
            }
        }
    }
    
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}
