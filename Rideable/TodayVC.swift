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

class TodayVC: UITableViewController {
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    private let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    private var FRC: NSFetchedResultsController<Day>!
    private var hours: [Hour]?
    
    //setup FRC
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.activityIndicatorShowing(showing: WeatherInfo.sharedInstance.isCurrentlyLoading, view: self.view)
    }
    
    //Add Observer to listen for data completion notifications.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBackgroundImage()
        /* Notification recieved from the WeatherInfo class. The classes obseving
         will listen for the download to be finished, update the table, and disable
         the activity indicator. */
        NotificationCenter.default.addObserver(forName: Constants.Notifications.REFRESH_NOTIFICATION, object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                //If VC is current window, display message and cancel loading indicator
                guard notification.object == nil && self.isViewLoaded && (self.view.window != nil) else{
                    if notification.object as? String != nil{
                        self.displayError(title: "Error", message: notification.object as! String)
                    }
                    self.activityIndicatorShowing(showing: false, view: self.view)
                    return
                }
                self.hours = self.sortHourArray(day: (self.FRC.fetchedObjects! as [Day]).first)
                self.activityIndicatorShowing(showing: false, view: self.view)
                self.tableView.reloadData()
            }
        }
    }
    
    private func setBackgroundImage(){
        let backgroundImage = UIImage(named: "backgroundDay")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        imageView.contentMode = .scaleAspectFill
    }
    
    //Create the FRC to fetch Tomorrows Weather
    private func setupFetchedResultsController(){
        let fetchedRequest: NSFetchRequest<Day> = Day.fetchRequest()
        fetchedRequest.predicate = NSPredicate(format: "type == %@", Constants.TypeOfDay.TODAY)
        fetchedRequest.sortDescriptors = []
        FRC = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: stack.context , sectionNameKeyPath: nil, cacheName: nil)
        fetchedRequest.fetchBatchSize = 1
        FRC.delegate = self
        
        do{
            try FRC.performFetch()
            self.hours = self.sortHourArray(day: (FRC.fetchedObjects! as [Day]).first)
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
        return section == 0 ? 1 : 12
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{ //Return Day Cell
            let cell = Bundle.main.loadNibNamed("TodayCell", owner: self, options: nil)?.first as! TodayCell
            
            return cell
        }else{ //Return Hour Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIdentifiers.hour, for: indexPath)
            if let label = cell.textLabel, FRC != nil, hours != nil {
                if let hour = hours?[indexPath.row]{
                    label.text = "\(self.militaryToCivilTime(time: Int(hour.time)))"
                }
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.view.frame.size.height - (self.navigationController?.navigationBar.frame.height)! - 19
        }else{
            return 70
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

//To notify of changes made to the table
extension TodayVC: NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
}

