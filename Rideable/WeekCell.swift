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
    var isObserving = false;
    class var expandedHeight: CGFloat { get { return 150 } }
    class var defaultHeight: CGFloat  { get { return 70  } }
    
    
    func initializeWeekCell(week: Week){
        weekday.text = week.weekday
        condition.text = week.condition
        icon.image = UIImage(named: week.icon!)
        condition.adjustsFontSizeToFitWidth = true
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
}
