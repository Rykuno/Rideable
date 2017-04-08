//
//  WeekVC.swift
//  Rideable
//
//  Created by Donny Blaine on 4/7/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

//
//  TodayVCTableViewController.swift
//  Rideable
//
//  Created by Donny Blaine on 3/2/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import UIKit
import CoreData
import SWRevealViewController
import EasyToast

class WeekVC: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    private var selectedIndexPath : IndexPath?
    private let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    private var FRC: NSFetchedResultsController<Week>!
    private var weekDays: [Week]?
    private var initialLoad = true
    private var notification: NSObjectProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "b3test")
        let imageView = UIImageView(image: image)
        tableView.backgroundView  = imageView
        imageView.contentMode = .scaleAspectFill
        setupFetchedResultsController()
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.activityIndicatorShowing(showing: WeatherInfo.sharedInstance.isCurrentlyLoading, view: self.view, tableView: self.tableView)
        setupNotifications() //Add Observer to listen for data completion notifications.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(notification)
    }
    
    
    //User action to refresh data
    @IBAction func refreshInfo(_ sender: Any) {
        activityIndicatorShowing(showing: true, view: self.view, tableView: self.tableView)
        WeatherInfo.sharedInstance.updateWeatherInfo()
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
                        self.displayMessage(message: notification.object as! String, view: self.view)
                    }
                    self.activityIndicatorShowing(showing: false, view: self.view, tableView: self.tableView)
                    return
                }
                self.activityIndicatorShowing(showing: false, view: self.view, tableView: self.tableView)
                self.tableView.reloadData()
            }
        }
    }
    
    
    //Create the FRC to fetch Tomorrows Weather
    private func setupFetchedResultsController(){
        let fetchedRequest: NSFetchRequest<Week> = Week.fetchRequest()
        fetchedRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        FRC = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: stack.context , sectionNameKeyPath: nil, cacheName: nil)
        fetchedRequest.fetchBatchSize = 1
        FRC.delegate = self
        
        do{
            try FRC.performFetch()
            
            //set weekdays for easy access
            if let weekObjects = (FRC.fetchedObjects) {
                print(weekObjects.count)
                weekDays = weekObjects
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeekCell", for: indexPath) as! WeekCell
        cell.initializeWeekCell(week: (weekDays?[indexPath.row])!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  self.isViewLoaded && (self.view.window != nil){
            if indexPath == selectedIndexPath {
                return WeekCell.expandedHeight
            } else {
                return WeekCell.defaultHeight
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
        if let cell = cell as? WeekCell {
            (cell as WeekCell).watchFrameChanges()
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? WeekCell {
            (cell as WeekCell).ignoreFrameChanges()
        }
    }
}

//To notify of changes made to the table
extension WeekVC: NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
}

