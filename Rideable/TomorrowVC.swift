//
//  TomorrowVC.swift
//  Rideable
//
//  Created by Donny Blaine on 3/3/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import UIKit
import CoreData

class TomorrowVC: UITableViewController {
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack

    fileprivate var fetchedResultsController: NSFetchedResultsController<Day>!
    private var hours: [Hour]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        self.activityIndicatoryShowing(showing: WeatherInfo.sharedInstance.isCurrentlyLoading, view: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(forName: Constants.Notifications.REFRESH_NOTIFICATION, object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                self.sortHourArray()
                self.activityIndicatoryShowing(showing: false, view: self.view)
                self.tableView.reloadData()
            }
        }
    }
    
    //Create the FRC to fetch Tomorrows Weather
    func setupFetchedResultsController(){
        let fetchedRequest: NSFetchRequest<Day> = Day.fetchRequest()
        fetchedRequest.predicate = NSPredicate(format: "type == %@", Constants.TypeOfDay.TOMORROW) 
        fetchedRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: stack.context , sectionNameKeyPath: nil, cacheName: nil)
        fetchedRequest.fetchBatchSize = 1
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
            self.sortHourArray()
        }catch{
            print(error.localizedDescription)
        }
    }
    
    //Since the FRC has no way of sorting the one-many entities(hours), we must do so here before displaying
    func sortHourArray(){
        let result = (self.fetchedResultsController.fetchedObjects! as [Day]).first
        self.hours = result?.hour?.allObjects as? [Hour]
        self.hours = self.hours?.sorted(by: { (a, b) -> Bool in
            if a.id < b.id {
                return true
            }else{
                return false
            }
        })
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
            if let label = cell.textLabel, fetchedResultsController != nil, let day = (fetchedResultsController.fetchedObjects! as [Day]).first {
                label.text = day.summary
            }
            return cell
        }else{ //Return Hour Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "hour", for: indexPath)
            if let label = cell.textLabel, fetchedResultsController != nil, hours != nil {
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
