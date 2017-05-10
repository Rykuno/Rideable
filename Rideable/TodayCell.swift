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
    @IBOutlet weak var windDirectionIcon: UIImageView!
    @IBOutlet weak var summaryView: UIView!
    
    private var day: Day!
    private let defaults = UserDefaults.standard
    private let isMetric: Bool = UserDefaults.standard.bool(forKey: Constants.Defaults.metricUnits)
    
    //MARK: - Cell Initialization
    //Initializes the cell with the day from the VC
    func initializeDayCell(day: Day?, shouldAnimate: Bool, isTodayCell: Bool){
        guard let day = day else{return}
        self.day = day
        initializeScore(isTodayCell: isTodayCell)
        initializePrecipitation()
        initializeWind()
        initializeCondition()
        initializeIcon()
        initializeTemperature(isTodayCell: isTodayCell)
        initializeSummary()
        initializeLocation()
        initializeUpdatedAt()
        initializeGauge(shouldAnimate: shouldAnimate, isTodayCell: isTodayCell)
    }
    
    private func initializeScore(isTodayCell: Bool){
        let calculatedScore = calculateScore(day: day, isTodayCell: isTodayCell)
        score.text = "\(calculatedScore)"
    }
    
    private func initializePrecipitation(){
        precip.text = "\(day.precipitation)%"
    }
    private func initializeHumidity(){
        humidity.text = day.humidity
    }
    private func initializeWind(){
        wind.text = "\(calculateWind(windInMph: day.wind, intValue: false))"
        self.windDirectionIcon.transform = CGAffineTransform(rotationAngle: CGFloat(Double(day.windDirectionDegrees) * Double.pi)/180)
    }
    private func initializeCondition(){
        condition.text = "\(parseCondition(day: day))"
        condition.adjustsFontSizeToFitWidth = true
    }
    private func initializeIcon(){
        if let image = UIImage(named: day.icon!) {
            icon.image = image
        }else{
            icon.image = UIImage(named: "unknown")
        }
    }
    private func initializeTemperature(isTodayCell: Bool){
        tempLow.text = "\(Constants.Symbols.downArrow)\(calculateTemperature(temp: day.tempLow))"
        tempHigh.text = "\(Constants.Symbols.upArrow)\(calculateTemperature(temp:day.tempHigh))"
        currentTemp.text = "\(calculateTemperature(temp: day.currentTemp))\(Constants.Symbols.degree)"
        
        //Configure labels dependent upon the type of day
        if isTodayCell{ //If the cell is today
            tempLow.text = "\(Constants.Symbols.downArrow)\(calculateTemperature(temp: day.tempLow))"
            tempHigh.text = "\(Constants.Symbols.upArrow)\(calculateTemperature(temp:day.tempHigh))"
            currentTemp.text = "\(calculateTemperature(temp: day.currentTemp))\(Constants.Symbols.degree)"
            defaults.set(calculateScore(day: day, isTodayCell: isTodayCell), forKey: "TodayScore")
        }else{ //If the cell is tomorrow lets replace current temperature with the high/low temp
            currentTemp.text = "\(Constants.Symbols.downArrow)\(calculateTemperature(temp: day.tempLow))\(Constants.Symbols.degree)\(Constants.Symbols.upArrow)\(calculateTemperature(temp:day.tempHigh))\(Constants.Symbols.degree)"
            currentTemp.font = currentTemp.font.withSize(35)
            currentTemp.textAlignment = .left
            currentTemp.adjustsFontSizeToFitWidth = true
            tempHigh.isHidden = true
            tempLow.isHidden = true
            location.isHidden = true
        }
    }
    
    private func initializeSummary(){
        daySummary.text = parseSentence(sentence: day.daySummary)
        summaryView.backgroundColor = UIColor.gray.withAlphaComponent(0.25)
        //daySummary.backgroundColor = UIColor.gray.withAlphaComponent(0.25)
        daySummary.numberOfLines = 2
        daySummary.adjustsFontSizeToFitWidth = true
    }
    private func initializeLocation(){
        location.text = "\(day.location!)"
        location.adjustsFontSizeToFitWidth = true
    }
    private func initializeUpdatedAt(){
        updatedAtLabel.text = "\(day.time!)"
        updatedAtLabel.adjustsFontSizeToFitWidth = true
    }
    private func initializeGauge(shouldAnimate: Bool, isTodayCell: Bool){
        if shouldAnimate == false {
            gauge.rate = CGFloat(calculateScore(day: day, isTodayCell: isTodayCell))
        }else{
            gauge.animateRate(TimeInterval(1), newValue: CGFloat(calculateScore(day: day, isTodayCell: isTodayCell))) { (success) in}
        }
        //gauge.startColor = mixGreenAndRed(score: calculateScore(day: day, isTodayCell: isTodayCell))
    } 
    
    //MARK: - Computing Functions
    //Calculate Score depending on user's weight/preferences
    private func calculateScore(day: Day, isTodayCell: Bool) -> Int {
        let tempWeight = defaults.double(forKey: Constants.Defaults.tempWeight)/100 * 1.5
        let humidityWeight = defaults.double(forKey: Constants.Defaults.humidityWeight)/100 * 1.5
        let precipWeight = defaults.double(forKey: Constants.Defaults.precipWeight)/100 * 1.5
        let windWeight = defaults.double(forKey: Constants.Defaults.windWeight)/100 * 1.5
        let humidityInt = Int((day.humidity?.extractDigits())!)
        
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
    
    private func calculateTemperature(temp: Int16) -> Int{
        if isMetric {
            let metricTemp = (Int(temp)-32) * 5/9
            return metricTemp
        }else{
            return (Int(temp))
        }
    }
    
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
    
    private func parseCondition(day: Day) -> String {
        guard var condition = day.summary else {
            return ""
        }
        
        let phraseToRemove = ["Chance of a", "Chance of"]
        for phrase in phraseToRemove {
            if let range = condition.range(of: phrase) {
                condition.removeSubrange(range)
            }
        }
        return condition
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
        if sentence.contains(",") {
            print(sentence)
            outputSentence.append(subStringArray[0])
            outputSentence = replaceUnitsInSentence(sentence: outputSentence)
            return outputSentence
        }
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
        guard let input = input else {
            return ""
        }
        
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
    
    //Depending on the score, calculate the color of the gauge
    private func mixGreenAndRed(score: Int) -> UIColor {
        let x = (Float(score)/100.00)/3
        return UIColor(hue:CGFloat(x), saturation:0.7, brightness:1.0, alpha:1.0)
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
    
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func extractDigits() -> String {
        return self.replacingOccurrences(of: "\\D", with: "", options: .regularExpression, range: (self.startIndex)..<(self.endIndex))
    }
}
