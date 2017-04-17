//
//  SettingsVC.swift
//  Rideable
//
//  Created by Donny Blaine on 3/13/17.
//  Copyright © 2017 RyStudios. All rights reserved.
//

import UIKit
import SWRevealViewController
import ASValueTrackingSlider
import EasyToast
import CoreLocation
import LocationPickerViewController

class SettingsVC: UITableViewController, ASValueTrackingSliderDataSource {
    
    
    @IBOutlet weak var timeMeasurementSwitch: UISwitch!
    @IBOutlet weak var unitMeasurementSwitch: UISwitch!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tempWeightLabel: UILabel!
    @IBOutlet weak var humidityWeightLabel: UILabel!
    @IBOutlet weak var precipWeightLabel: UILabel!
    @IBOutlet weak var windWeightLabel: UILabel!
    @IBOutlet weak var tempStepper: UIStepper!
    @IBOutlet weak var humidityStepper: UIStepper!
    @IBOutlet weak var precipStepper: UIStepper!
    @IBOutlet weak var windStepper: UIStepper!
    @IBOutlet weak var tempSlider: ASValueTrackingSlider!
    @IBOutlet weak var humiditySlider: ASValueTrackingSlider!
    @IBOutlet weak var precipSlider: ASValueTrackingSlider!
    @IBOutlet weak var windSlider: ASValueTrackingSlider!
    @IBOutlet weak var locationServicesSwitch: UISwitch!
    
    private let defaults = UserDefaults.standard
    
    @IBOutlet weak var locationButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let sliderArray: [ASValueTrackingSlider] = [tempSlider, humiditySlider, precipSlider, windSlider]
        setupSliders(sliders: sliderArray)
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
    }
    
    @IBAction func locationServiceSwitched(_ sender: UISwitch) {
        if sender.isOn{
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
                locationButton.isEnabled = false
                WeatherInfo.sharedInstance.setUpdateOverrideStatus(shouldOverride: true)
            }else{
                presentOptionsDialog()
                sender.isOn = false
            }
        }else{
            locationButton.isEnabled = true
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //set switch values
        unitMeasurementSwitch.setOn(defaults.bool(forKey: Constants.Defaults.metricUnits), animated: true)
        timeMeasurementSwitch.setOn(defaults.bool(forKey: Constants.Defaults.standardTime), animated: true)
        locationServicesSwitch.setOn(defaults.bool(forKey: Constants.Defaults.userPrefersLocationServices), animated: false)
        
        //Set slider values
        tempSlider.value = defaults.float(forKey: Constants.Defaults.temp)
        humiditySlider.value = defaults.float(forKey: Constants.Defaults.humidity)
        precipSlider.value = defaults.float(forKey: Constants.Defaults.precip)
        windSlider.value = defaults.float(forKey: Constants.Defaults.wind)
        windSlider.maximumValue = 50
        
        //set stepper values
        tempStepper.value = defaults.double(forKey: Constants.Defaults.tempWeight)
        humidityStepper.value = defaults.double(forKey: Constants.Defaults.humidityWeight)
        precipStepper.value = defaults.double(forKey: Constants.Defaults.precipWeight)
        windStepper.value = defaults.double(forKey: Constants.Defaults.windWeight)
        updateStepperState()
        
        //set stepper label values
        tempWeightLabel.text = "\(Int(tempStepper.value))%"
        humidityWeightLabel.text = "\(Int(humidityStepper.value))%"
        precipWeightLabel.text = "\(Int(precipStepper.value))%"
        windWeightLabel.text = "\(Int(windStepper.value))%"
        
        // Select Location Button
        locationButton.isEnabled = !locationServicesSwitch.isOn
        
        if let displayLocation = defaults.string(forKey: Constants.Defaults.displayLocation) {
            locationButton.setTitle(displayLocation, for: .normal)
        }else{
            locationButton.setTitle("Select Location", for: .normal)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveSettings()
    }
    
    private func setupSliders(sliders: [ASValueTrackingSlider]){
        for slider in sliders{
            slider.dataSource = self
            slider.popUpViewArrowLength = 0.1
            slider.popUpViewColor = self.view.tintColor
        }
    }
    
    internal func slider(_ slider: ASValueTrackingSlider!, stringForValue value: Float) -> String! {
        switch slider.accessibilityIdentifier! {
        case "temp":
            return "\(Int(value))°"
        case "humidity":
            return "\(Int(value))%"
        case "precip":
            return "\(Int(value))%"
        case "wind":
            return unitMeasurementSwitch.isOn ? "\(Int(value)) kph" : "\(Int(value)) mph"
        default:
            return String(Int(value))
        }
    }
    
    @IBAction func save(_ sender: Any) {
        saveSettings()
        self.displayMessage(message: Constants.Notifications.Messages.settingsUpdated, view: self.view)
    }
    
    private func saveSettings(){
        defaults.set(tempSlider.value, forKey: Constants.Defaults.temp)
        defaults.set(humiditySlider.value, forKey: Constants.Defaults.humidity)
        defaults.set(precipSlider.value, forKey: Constants.Defaults.precip)
        defaults.set(windSlider.value, forKey: Constants.Defaults.wind)
        defaults.set(unitMeasurementSwitch.isOn, forKey: Constants.Defaults.metricUnits)
        defaults.set(timeMeasurementSwitch.isOn, forKey: Constants.Defaults.standardTime)
        defaults.set(tempStepper.value, forKey: Constants.Defaults.tempWeight)
        defaults.set(humidityStepper.value, forKey: Constants.Defaults.humidityWeight)
        defaults.set(precipStepper.value, forKey: Constants.Defaults.precipWeight)
        defaults.set(windStepper.value, forKey: Constants.Defaults.windWeight)
        defaults.set(locationServicesSwitch.isOn, forKey: Constants.Defaults.userPrefersLocationServices)
    }
    
    private func updateStepperState(){
        let temp = tempStepper.value
        let humidity = humidityStepper.value
        let precip = precipStepper.value
        let wind = windStepper.value
        let total = temp + humidity + precip + wind
        if total >= 100 {
            tempStepper.maximumValue = tempStepper.value
            humidityStepper.maximumValue = humidityStepper.value
            precipStepper.maximumValue = precipStepper.value
            windStepper.maximumValue = windStepper.value
        }else{
            tempStepper.maximumValue = 100
            humidityStepper.maximumValue = 100
            precipStepper.maximumValue = 100
            windStepper.maximumValue = 100
        }
    }
    
    private func presentOptionsDialog() {
        let alertController = UIAlertController (title: "Location Services Disabled", message: "In order to have the most accurate weather, please allow this app access to Location Services", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Enable Services", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Counters
    
    @IBAction func tempCounter(_ sender: UIStepper) {
        let stepperValue = Int(sender.value)
        tempWeightLabel.text = "\(stepperValue)%"
        updateStepperState()
    }
    
    @IBAction func humidityCounter(_ sender: UIStepper) {
        let stepperValue = Int(sender.value)
        humidityWeightLabel.text = "\(stepperValue)%"
        updateStepperState()
    }
    
    @IBAction func precipCounter(_ sender: UIStepper) {
        let stepperValue = Int(sender.value)
        precipWeightLabel.text = "\(stepperValue)%"
        updateStepperState()
    }
    
    @IBAction func windCounter(_ sender: UIStepper) {
        let stepperValue = Int(sender.value)
        windWeightLabel.text = "\(stepperValue)%"
        updateStepperState()
    }
    
    //dismisses keyboard upon tapping outside
    private func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func locationPicker(_ sender: Any) {
        let locationPicker = LocationPicker()
        locationPicker.selectCompletion = { (pickedLocationItem) in
            self.parseFormattedAddress(location: pickedLocationItem)
            WeatherInfo.sharedInstance.setUpdateOverrideStatus(shouldOverride: true)
            self.navigationController?.popToRootViewController(animated: true)
        }
        navigationController!.pushViewController(locationPicker, animated: true)
    }
    
    
    //Gets City,State,Coords, and Zip from a location
    private func parseFormattedAddress(location: LocationItem){
        
        // Latitude and Longitude
        if let latitude = location.coordinate?.latitude, let longitude = location.coordinate?.longitude {
            let latLon = "\(latitude),\(longitude)"
            defaults.set(latLon, forKey: Constants.Defaults.location)
        }
        
        // Location name
        if let state = location.addressDictionary?["State"] as? NSString, let city = location.addressDictionary?["City"] as? NSString
        {
            let cityState = "\(city), \(state)"
            locationButton.setTitle(cityState, for: .normal)
            defaults.set(cityState, forKey: Constants.Defaults.displayLocation)
        }
        
        // Zip code
        if let zip = location.addressDictionary?["ZIP"] as? NSString
        {
            print(zip)
        }
        
    }
}

extension String {
    //Removes whitespace form string for use in URL
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
