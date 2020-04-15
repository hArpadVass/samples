//
//  SchedulerAdvancedViewController.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 1/28/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

protocol AdvancedSettingsChosenDelegate {
    func AdvancedTimeControls(steps : UInt8, stepsResolution : StepResolution, secondValue : Int, minuteValue : Int, hourValue : Int, strTranstime: String)
}

class SchedulerAdvancedViewController: UITableViewController {
    ///buttons
    @IBOutlet var topButtons: [UIButton]!
    
    @IBOutlet weak var transtionTimeSlider: UISlider!
    @IBOutlet weak var transitionTimePicker: BubblyTimeView!
    @IBOutlet weak var transitionTimeSlider: UILabel!
    @IBOutlet weak var transitionTimeLabel: UILabel!
    private var steps: UInt8 = 0
    private var delay: UInt8 = 0
    private var stepResolution: StepResolution = .hundredsOfMilliseconds
    ///second switches

    @IBOutlet weak var anySecondSwitch     : UISwitch!
    @IBOutlet weak var everyFifteenSwitchS : UISwitch!
    @IBOutlet weak var everyTwentySwitchS  : UISwitch!
    @IBOutlet weak var randomSecondSwitch  : UISwitch!
    
    var secondValue    : Int = 0x3C
    var secondSwitches : [UISwitch] = []
    var allSecondSwitchesAreOff = false{
        willSet(newValue){
            if newValue != self.allSecondSwitchesAreOff{
                secondSectionHasOneRow = !secondSectionHasOneRow
            }
        }
    }
    var secondSectionHasOneRow : Bool = true{
        didSet{
            insertDeleteRows(row: 1
                , section: 2
                , evaluation: self.secondSectionHasOneRow)
        }
    }

    ///minute switches
    @IBOutlet var minuteSwitches: [UISwitch]!
    var minuteValue : Int = 0x3C
    var allMinuteSwitchesAreOff = false {
        willSet(newValue){
            if newValue != self.allMinuteSwitchesAreOff{
                minuteSectionHasOneRow = !minuteSectionHasOneRow
            }
        }
    }
    var minuteSectionHasOneRow : Bool = true{
        didSet{
            insertDeleteRows(row: 1
                , section: 3
                , evaluation: self.minuteSectionHasOneRow)
        }
    }
        
    @IBAction func savedPressed(_ sender: Any) {
        let sValue = allSecondSwitchesAreOff ? secondPicker.pickerValue : secondValue
        let mValue = allMinuteSwitchesAreOff ? minutePicker.pickerValue : minuteValue
        let hValue = allHourSwitchesAreOff   ? hourPicker.pickerValue   : hourValue

        
        advancedTimeChosenDelegate?.AdvancedTimeControls(steps: steps
            , stepsResolution: stepResolution
            , secondValue: sValue
            , minuteValue: mValue
            , hourValue: hValue
            , strTranstime: transitionTimeSlider.text ?? "not available")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /// hour switches
    @IBOutlet var hourSwitches: [UISwitch]!
    var hourValue : Int = 0x18
    var allHourSwitchesAreOff : Bool = false{
        willSet(newValue){
            if newValue != self.allHourSwitchesAreOff{
                hourSectionHasOneRow = !hourSectionHasOneRow
            }
        }
    }
    var hourSectionHasOneRow : Bool = true {
        didSet{
            insertDeleteRows(row: 1
                , section: 4
                , evaluation: self.hourSectionHasOneRow)
        }
    }
    
    var isAnySecond = false
    var isAnyMinute = false
    var isAnyHour   = false
    var advancedTimeChosenDelegate : AdvancedSettingsChosenDelegate?

    @IBOutlet weak var secondPicker: SecondTimePicker!
    @IBOutlet weak var minutePicker: MinuteTimePicker!
    @IBOutlet weak var hourPicker  : HourTimePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topButtons.forEach { (button) in button.tintColor = .white }
        transtionTimeSlider.tintColor = ApplicationColors.color.secondary
        
        tableView.allowsSelection = false
        if #available(iOS 11.0, *) {
            self.view.layer.cornerRadius  = 10
            self.view.layer.maskedCorners = [.layerMinXMinYCorner
                                             ,.layerMaxXMinYCorner]
        }
        secondSwitches = [anySecondSwitch
            , everyFifteenSwitchS
            , everyTwentySwitchS
            , randomSecondSwitch]
        transitionTimeLabel.text = "0 sec"
    }
    
    @IBAction func transitionTimeDidChange(_ sender: UISlider) {
        transitionTimeSelected(sender.value)
    }
    
    func transitionTimeSelected(_ value: Float) {
        switch value {
        case let period where period < 1.0:
            transitionTimeLabel.text = "Immediate"
            steps = 0
            stepResolution = .hundredsOfMilliseconds
        case let period where period >= 1 && period < 10:
            transitionTimeLabel.text = "\(Int(period) * 100) ms"
            steps                    = UInt8(period)
            stepResolution           = .hundredsOfMilliseconds
        case let period where period >= 10 && period < 63:
            transitionTimeLabel.text = String(format: "%.1f sec", floorf(period) / 10)
            steps                    = UInt8(period)
            stepResolution           = .hundredsOfMilliseconds
        case let period where period >= 63 && period < 116:
            transitionTimeLabel.text = "\(Int(period) - 56) sec"
            steps                    = UInt8(period) - 56
            stepResolution           = .seconds
        case let period where period >= 116 && period < 119:
            transitionTimeLabel.text = "\(Int((period + 4) / 60) - 1) min 0\(Int(period + 4) % 60) sec"
            steps                    = UInt8(period) - 56
            stepResolution           = .seconds
        case let period where period >= 119 && period < 175:
            let sec                  = (Int(period + 2) % 6) * 10
            let secString            = sec == 0 ? "00" : "\(sec)"
            transitionTimeLabel.text = "\(Int(period + 2) / 6 - 19) min \(secString) sec"
            steps                    = UInt8(period) - 112
            stepResolution           = .tensOfSeconds
        case let period where period >= 175 && period < 179:
            transitionTimeLabel.text = "\((Int(period) - 173) * 10) min"
            steps                    = UInt8(period) - 173
            stepResolution           = .tensOfMinutes
        case let period where period >= 179:
            let min                  = (Int(period) - 173) % 6 * 10
            let minString            = min == 0 ? "00" : "\(min)"
            transitionTimeLabel.text = "\(Int(period + 1) / 6 - 29) h \(minString) min"
            steps                    = UInt8(period) - 173
            stepResolution           = .tensOfMinutes
        default:
            break
        }
    }
    
    ////second switches
    @IBAction func secondSwitched(_ sender: UISwitch) {
        manageToggle(switches: secondSwitches, sender: sender)
        secondValue    = manageSwitchStatement(sender: sender)
        let onSwitches = secondSwitches.filter({ $0.isOn })
        allSecondSwitchesAreOff = onSwitches.count == 0 ? true : false
    }
    
    ///minute switches
    @IBAction func minuteSwitched(_ sender: UISwitch) {
        manageToggle(switches: minuteSwitches, sender: sender)
        minuteValue    = manageSwitchStatement(sender: sender)
        let onSwitches = minuteSwitches.filter({ $0.isOn })
        allMinuteSwitchesAreOff = onSwitches.count == 0 ? true : false

    }
    
    @IBAction func hourSwitched(_ sender: UISwitch) {
        manageToggle(switches: hourSwitches, sender: sender)
        switch sender.tag {
        case 0:
            hourValue = 0x18
        case 1:
            hourValue = 0x19
        default:
            print("something went wrong - hour switch statement")
        }
        let onSwitches = hourSwitches.filter({ $0.isOn })
        allHourSwitchesAreOff = onSwitches.count == 0 ? true : false
    }
    
    
    ///turns on and off toggles for selected  switch group
    func manageToggle(switches : [UISwitch], sender : UISwitch){
        switches.forEach { (toggle) in
            if toggle.tag != sender.tag{
                toggle.isOn = false
            }
        }
    }
    
    /// seconds and minute share the same values so its handled here
    func manageSwitchStatement(sender : UISwitch) -> Int{
        switch sender.tag {
        case 0:
            ///any
            return 0x3C
        case 1:
            ///every 15
            return 0x3D
        case 2:
            ///e 20
            return 0x3E
        case 3:
            /// random
           return 0x3F
        default:
            print("something went wrong ")
            return 0x3C
        }
        
    }
    ///insert and deletes static table view rows pending the status of the switches
    /// evaluated in the did set of the respecdtive variables
    func insertDeleteRows(row: Int, section: Int, evaluation : Bool){
        if evaluation{
            tableView.deleteRows(at: [IndexPath(row: row, section: section)]
                , with: .fade)
        }else{
            tableView.insertRows(at: [IndexPath(row: row, section: section)]
                , with: .fade)
        }
    }
   
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0,6:
            return 60
        default:
            return 30
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return secondSectionHasOneRow ? 1 : 2
        case 3:
            return minuteSectionHasOneRow ? 1 : 2
        case 4:
            return hourSectionHasOneRow   ? 1 : 2
        case 5:
            return 0
        default:
            print("something went wrong")
        }
        return 0
    }
}
