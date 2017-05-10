//
//  SWVCViewController.swift
//  ShouldIRide
//
//  Created by Donny Blaine on 2/11/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import UIKit
import SWRevealViewController
import Social

class SWVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let imagesArray = [Constants.Menu.Icons.weatherIcons, Constants.Menu.Icons.optionsIcons, Constants.Menu.Icons.shareIcons]
    let optionsArray = [Constants.Menu.Items.weatherItems, Constants.Menu.Items.optionItems, Constants.Menu.Items.shareItems]
    let sectionsArray = Constants.Menu.Sections.sections
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTableviewBackground()
        setNeedsFocusUpdate()
    }
    
    func setTableviewBackground() {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = optionsArray[indexPath.section][indexPath.row]
        cell.imageView?.image = imagesArray[indexPath.section][indexPath.row]
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.layer.masksToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont(name: "Avenir Next Medium", size: 20)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Avenir Next Condensed", size: 28)
        header.textLabel?.textColor = UIColor(hex: "e5601d")
        header.backgroundColor = UIColor.clear
        header.backgroundView = tableView.backgroundView
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsArray[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let revealViewController: SWRevealViewController = self.revealViewController()
        
        let cell = tableView.cellForRow(at: indexPath)
 
        if cell?.textLabel?.text == "Today" {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let todayVC = mainStoryboard.instantiateViewController(withIdentifier: "TodayVC")
            let newFrontViewController = UINavigationController.init(rootViewController: todayVC)
            revealViewController.pushFrontViewController(newFrontViewController, animated: true)
        }
        if cell?.textLabel?.text == "Tomorrow" {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let tomorrowVC = mainStoryboard.instantiateViewController(withIdentifier: "TomorrowVC")
            let newFrontViewController = UINavigationController.init(rootViewController: tomorrowVC)
            revealViewController.pushFrontViewController(newFrontViewController, animated: true)
        }
        if cell?.textLabel?.text == "10 Day" {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let weekVC = mainStoryboard.instantiateViewController(withIdentifier: "WeekVC")
            let newFrontViewController = UINavigationController.init(rootViewController: weekVC)
            revealViewController.pushFrontViewController(newFrontViewController, animated: true)
        }
        
        if cell?.textLabel?.text == "Settings" {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let weekVC = mainStoryboard.instantiateViewController(withIdentifier: "SettingsVC")
            let newFrontViewController = UINavigationController.init(rootViewController: weekVC)
            revealViewController.pushFrontViewController(newFrontViewController, animated: true)
        }
        
        if cell?.textLabel?.text == "Facebook" {
            if let score = UserDefaults.standard.object(forKey: "TodayScore") {
                let vc = SLComposeViewController(forServiceType:SLServiceTypeFacebook)
                vc?.add(UIImage(named: "shareIcon")!)
                vc?.add(URL(string: ""))
                vc?.setInitialText("Rideable scores today as a \(score)! Who's up for a ride?")
                self.present(vc!, animated: true, completion: nil)
            }
        }
        
        if cell?.textLabel?.text == "Twitter" {
            if let score = UserDefaults.standard.object(forKey: "TodayScore") {
                let vc = SLComposeViewController(forServiceType:SLServiceTypeTwitter)
                vc?.add(UIImage(named: "shareIcon")!)
                vc?.add(URL(string: ""))
                vc?.setInitialText("Rideable scores today as a \(score)! Who's up for a ride?")
                self.present(vc!, animated: true, completion: nil)
            }
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}
