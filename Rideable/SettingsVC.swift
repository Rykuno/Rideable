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

class SettingsVC: UITableViewController, ASValueTrackingSliderDataSource {
    
    
    @IBOutlet weak var captureWeatherButton: UIButton!
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
    @IBOutlet weak var locationTextField: UITextField!
    let defaults = UserDefaults.standard
     
    override func viewDidLoad() {
        super.viewDidLoad()
        let sliderArray: [ASValueTrackingSlider] = [tempSlider, humiditySlider, precipSlider, windSlider]
        setupSliders(sliders: sliderArray)
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        locationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unitMeasurementSwitch.setOn(defaults.bool(forKey: Constants.Defaults.metricUnits), animated: true)
        timeMeasurementSwitch.setOn(defaults.bool(forKey: Constants.Defaults.standardTime), animated: true)
          
        tempSlider.value = defaults.float(forKey: Constants.Defaults.temp)
        humiditySlider.value = defaults.float(forKey: Constants.Defaults.humidity)
        precipSlider.value = defaults.float(forKey: Constants.Defaults.precip)
        windSlider.value = defaults.float(forKey: Constants.Defaults.wind)

        tempStepper.value = defaults.double(forKey: Constants.Defaults.tempWeight)
        humidityStepper.value = defaults.double(forKey: Constants.Defaults.humidityWeight)
        precipStepper.value = defaults.double(forKey: Constants.Defaults.precipWeight)
        windStepper.value = defaults.double(forKey: Constants.Defaults.windWeight)
        updateStepperState()
        
        locationTextField.text = defaults.string(forKey: Constants.Defaults.location)
    }
    
    private func setupSliders(sliders: [ASValueTrackingSlider]){
        for slider in sliders{
            slider.dataSource = self
            slider.popUpViewArrowLength = 0.1
            slider.popUpViewColor = self.view.tintColor
        }
    } 
    
    func slider(_ slider: ASValueTrackingSlider!, stringForValue value: Float) -> String! {
        switch slider.accessibilityIdentifier! {
        case "temp":
            return "\(Int(value))°"
        case "humidity":
            return "\(Int(value))%"
        case "precip":
            return "\(Int(value))%"
        case "wind":
            return "\(Int(value))"
        default:
            return String(Int(value))
        }
    }
    
    @IBAction func save(_ sender: Any) {
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
        defaults.set(locationTextField.text, forKey: Constants.Defaults.location)
        defaults.synchronize()
        
        self.view.showToast("Settings Updated!", position: .bottom, popTime: 1.0, dismissOnTap: true)
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
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        WeatherInfo.sharedInstance.setUpdateOverrideStatus(shouldOverride: true) 
    }
}
