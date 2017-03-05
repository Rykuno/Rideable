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

class TomorrowVC: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    private let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    private var FRC: NSFetchedResultsController<Day>!
    private var hours: [Hour]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.activityIndicatorShowing(showing: WeatherInfo.sharedInstance.isCurrentlyLoading, view: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBackgroundImage()
        /* Notification recieved from the WeatherInfo class. The classes obseving
         will listen for the download to be finished, update the table, and disable
         the activity indicator. */
        NotificationCenter.default.addObserver(forName: Constants.Notifications.REFRESH_NOTIFICATION, object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                
                /*If VC is current window, display message and cancel loading indicator,
                  else, we will just set the variables */
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
        let backgroundImage = UIImage(named: "backgroundNight")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        imageView.contentMode = .scaleAspectFill
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
            self.hours = self.sortHourArray(day: (self.FRC.fetchedObjects! as [Day]).first)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "day", for: indexPath)
            if let label = cell.textLabel, FRC != nil, let day = (FRC.fetchedObjects! as [Day]).first {
                label.text = day.summary
            }
            return cell
        }else{ //Return Hour Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "hour", for: indexPath)
            if let label = cell.textLabel, FRC != nil, hours != nil {
                if let hour = hours?[indexPath.row]{
                    label.text = "\(self.militaryToCivilTime(time: Int(hour.time)))"
                }
            }
            return cell
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
