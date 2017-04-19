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
    //MARK: - Outlets
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    //MARK: - Variables
    private var selectedIndexPath : IndexPath?
    private let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    private var FRC: NSFetchedResultsController<Week>!
    private var weekDays: [Week]?
    private var notification: NSObjectProtocol!
    
    //MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setStaticBackground()
        setupFetchedResultsController()
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        activityIndicatorShowing(showing: WeatherInfo.sharedInstance.isCurrentlyLoading, view: view, tableView: tableView)
        setupNotifications() //Add Observer to listen for data completion notifications.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForRefreshOverrideStatus(view: view, tableView: tableView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(notification)
    }
    
    //MARK: - IBActions
    @IBAction func refreshInfo(_ sender: Any) {
        activityIndicatorShowing(showing: true, view: self.view, tableView: self.tableView)
        WeatherInfo.sharedInstance.messageShown = false
        WeatherInfo.sharedInstance.updateWeatherInfo()
        tableView.reloadData()
    }
    
    //MARK: - Class Functions
    private func setStaticBackground(){
        let image = UIImage(named: "week")
        let imageView = UIImageView(image: image)
        tableView.backgroundView = imageView
    }
    
    private func setupNotifications(){
        /* Notification recieved from the WeatherInfo class. The classes obseving
         will listen for the download to be finished, update the table, and disable
         the activity indicator. */
        guard notification == nil else{
            return
        }
        
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
    
    private func setupFetchedResultsController(){
        let fetchedRequest: NSFetchRequest<Week> = Week.fetchRequest()
        fetchedRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        FRC = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: stack.context , sectionNameKeyPath: nil, cacheName: nil)
        fetchedRequest.fetchBatchSize = 1
        FRC.delegate = self
        
        do{
            try FRC.performFetch()
            if let weekObjects = (FRC.fetchedObjects) {
                print(weekObjects.count)
                weekDays = weekObjects
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // MARK: - TableView Functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ((FRC.fetchedObjects?.count)! == 0) && (currentReachabilityStatus == .notReachable){
            tableView.separatorStyle = .none
            return 1
        }
        tableView.separatorStyle = .singleLine
        if let days = weekDays?.count, (weekDays?.count)! > 0{
            return days
        }else{
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (weekDays?.count)! > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeekCell", for: indexPath) as! WeekCell
            cell.initializeWeekCell(week: (weekDays?[indexPath.row])!)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeekCell", for: indexPath) as! WeekCell
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((FRC.fetchedObjects?.count)! == 0) && (currentReachabilityStatus == .notReachable) {
            return 0
        }
        
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
        guard let dayCount = weekDays?.count, dayCount > 1 else{
            return
        }
        
        if selectedIndexPath?.row == dayCount-1 {
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

