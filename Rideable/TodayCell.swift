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
        
    
    func initializeDayCell(day: Day?, shouldAnimate: Bool){
        guard let day = day else{
            return
        }
        daySummary.numberOfLines = 2
        updatedAtLabel.text = "\(day.time!)"
        score.text = "\(calculateScore(day: day))"
        condition.text = day.summary
        icon.image = UIImage(named: day.icon!)
        tempLow.text = "\(Constants.Symbols.downArrow)\(day.tempLow)"
        tempHigh.text = "\(Constants.Symbols.upArrow)\(day.tempHigh)"
        currentTemp.text = "\(day.currentTemp)\(Constants.Symbols.degree)"
        daySummary.text = day.daySummary
        daySummary.backgroundColor = UIColor.gray.withAlphaComponent(0.25)
        feelsLike.text = "Feels like \(day.feelsLike)"
        if !shouldAnimate {
            gauge.rate = CGFloat(calculateScore(day: day))
        }else{
            gauge.animateRate(TimeInterval(1), newValue: CGFloat(calculateScore(day: day))) { (success) in}
        }
    }
    
    private func calculateScore(day: Day) -> Int {
        let defaults = UserDefaults.standard
        let tempWeight = defaults.double(forKey: Constants.Defaults.tempWeight)/100
        let humidityWeight = defaults.double(forKey: Constants.Defaults.humidityWeight)/100
        let precipWeight = defaults.double(forKey: Constants.Defaults.precipWeight)/100
        let windWeight = defaults.double(forKey: Constants.Defaults.windWeight)/100
        
        let humidityInt = Int((day.humidity?.replacingOccurrences(of: "\\D", with: "", options: .regularExpression, range: (day.humidity?.startIndex)!..<(day.humidity?.endIndex)!))!)
        
        let tempDiff = abs(defaults.double(forKey: Constants.Defaults.temp)-Double(day.currentTemp))
        let humidityDiff = abs(defaults.double(forKey: Constants.Defaults.humidity)-Double(humidityInt!))
        let precipDiff = abs(defaults.double(forKey: Constants.Defaults.precip)-Double(day.precipitation))
        let windDiff = abs(defaults.double(forKey: Constants.Defaults.wind)-Double(day.wind))
        
        return Int(100 - (tempWeight * tempDiff) - (humidityWeight * humidityDiff) - (precipWeight * precipDiff) - (windWeight * windDiff))
        
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
