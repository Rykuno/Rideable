//
//  SWVCViewController.swift
//  ShouldIRide
//
//  Created by Donny Blaine on 2/11/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import UIKit
import SWRevealViewController

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
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = optionsArray[indexPath.section][indexPath.row]
        cell.imageView?.image = imagesArray[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Futura", size: 20)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsArray[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
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
    }
}
