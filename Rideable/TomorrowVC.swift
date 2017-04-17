//
//  TomorrowVC.swift
//  Rideable
//
//  Created by Donny Blaine on 3/3/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import UIKit
import CoreData
import SWRevealViewController
import EasyToast

class TomorrowVC: UITableViewController {
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    private var selectedIndexPath : IndexPath?
    private let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    private var FRC: NSFetchedResultsController<Day>!
    private var hours: [Hour]?
    private var initialLoad = true
    private var notification: NSObjectProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground()
        setupFetchedResultsController()
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.activityIndicatorShowing(showing: WeatherInfo.sharedInstance.isCurrentlyLoading, view: self.view, tableView: self.tableView)
        setupNotifications() //Add Observer to listen for data completion notifications.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let icon = self.FRC.fetchedObjects?.first?.icon {
            self.setBackgroundImage(day: Constants.TypeOfDay.TOMORROW, tableView: tableView, condition: icon)
        }
        if WeatherInfo.sharedInstance.allowUpdateOverride {
            activityIndicatorShowing(showing: true, view: self.view, tableView: self.tableView)
            WeatherInfo.sharedInstance.updateWeatherInfo()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(notification)
    }
    
    //User action to refresh data
    @IBAction func refreshInfo(_ sender: Any) {
        activityIndicatorShowing(showing: true, view: self.view, tableView: self.tableView)
        WeatherInfo.sharedInstance.updateWeatherInfo()
        self.tableView.reloadData()
    }
    
    private func setBackground(){
        let image = UIImage(named: "tomorrow")!
        let imageView = UIImageView(image: image)
        
        tableView.backgroundView = imageView
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.black
    }
    
    private func setupNotifications(){
        /* Notification recieved from the WeatherInfo class. The classes obseving
         will listen for the download to be finished, update the table, and disable
         the activity indicator. */
        notification = NotificationCenter.default.addObserver(forName: Constants.Notifications.REFRESH_NOTIFICATION, object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                //If VC is current window, display message and cancel loading indicator
                guard notification.object == nil && self.isViewLoaded && (self.view.window != nil) else{
                    if notification.object as? String != nil{
                        self.displayMessage(message: notification.object as! String)
                    }
                    self.activityIndicatorShowing(showing: false, view: self.view, tableView: self.tableView)
                    return
                }
                self.hours = self.sortHourArray(day: (self.FRC.fetchedObjects! as [Day]).first)
                self.activityIndicatorShowing(showing: false, view: self.view, tableView: self.tableView)
                self.tableView.reloadData()
            }
        }
    }
    
    private func displayMessage(message: String){
        switch message {
        case Constants.Notifications.Messages.alreadyUpdated:
            self.view.showToast(message, position: .bottom, popTime: 1.0, dismissOnTap: true)
            break;
        default:
            self.view.showToast(message, tag: nil, position: .bottom, popTime: 2.5, dismissOnTap: true, bgColor: UIColor.red, textColor: UIColor.white, font: nil)
            break;
        }
    }
    
    //Create the FRC to fetch Tomorrows Weather
    private func setupFetchedResultsController(){
        let fetchedRequest: NSFetchRequest<Day> = Day.fetchRequest()
        fetchedRequest.predicate = NSPredicate(format: "type == %@", Constants.TypeOfDay.TOMORROW)
        fetchedRequest.sortDescriptors = []
        FRC = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: stack.context , sectionNameKeyPath: nil, cacheName: nil)
        fetchedRequest.fetchBatchSize = 1
        FRC.delegate = self
        
        do{
            try FRC.performFetch()
            
            //set hours for easy access
            if let dayObject = (FRC.fetchedObjects)!.first {
                self.hours = self.sortHourArray(day: dayObject)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        //Only 2 sections, Day and Hour.
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Section 0 - Day cell(count = 1)
        //Section 1 - Hour cell(count = 12)
        if ((FRC.fetchedObjects?.count)! == 0) && (currentReachabilityStatus == .notReachable){
            tableView.separatorStyle = .none
            return section == 0 ? 1 : 0
        }else{
            return section == 0 ? 1 : 12
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{ //Return Day Cell
            if initialLoad {
                let cell = Bundle.main.loadNibNamed("TodayCell", owner: self, options: nil)?.first as! TodayCell
                cell.initializeDayCell(day: (FRC.fetchedObjects! as [Day]).first, shouldAnimate: true, isTodayCell: false)
                initialLoad = false
                return cell
            }else{
                let cell = Bundle.main.loadNibNamed("TodayCell", owner: self, options: nil)?.first as! TodayCell
                cell.initializeDayCell(day: (FRC.fetchedObjects! as [Day]).first, shouldAnimate: false, isTodayCell: false)
                return cell
            }
        }else{ //Return Hour Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "HourCell", for: indexPath) as! HourCell
            cell.initializeHourCell(hour: hours?[indexPath.row])
            return cell
        }
    }
    
    //Set row height depending on if the row should be expanded or not
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  self.isViewLoaded && (self.view.window != nil){
            if indexPath.section == 0 {
                return self.view.frame.size.height - (self.navigationController?.navigationBar.frame.height)! - 19
            }else{
                if indexPath == selectedIndexPath {
                    return HourCell.expandedHeight
                } else {
                    return HourCell.defaultHeight
                }
            }
        }
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousIndexPath = selectedIndexPath
        if indexPath == selectedIndexPath {
            selectedIndexPath = nil
        } else {
            selectedIndexPath = indexPath
        }
        
        var indexPaths : Array<IndexPath> = []
        if let previous = previousIndexPath {
            indexPaths += [previous]
        }
        if let current = selectedIndexPath {
            indexPaths += [current]
        }
        if indexPaths.count > 0 {
            tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
        }
        
        // If the selected row is the last, scroll the tableview up a little.
        if selectedIndexPath?.row == 11 {
            tableView.scrollToRow(at: indexPaths.last!, at: .bottom, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? HourCell {
            (cell as HourCell).watchFrameChanges()
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? HourCell {
            (cell as HourCell).ignoreFrameChanges()
        }
    }
}

//To notify of changes made to the table
extension TomorrowVC: NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
}

