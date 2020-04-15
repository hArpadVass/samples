//
//  BubsSchedulerViewController.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 11/15/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

class BubsSchedulerViewController: UIViewController {
    
    ///animating constraints
    @IBOutlet weak var advancedViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var testConstraint: NSLayoutConstraint!
    @IBOutlet weak var bTest: NSLayoutConstraint!
    @IBOutlet var dayButtons: [BubsSchedulerWeekDayButton]!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var selectedTimeLabel: UILabel!
    @IBOutlet weak var functionalitySegmentControl: UISegmentedControl!
    
    //MARK: add selected group
    let manager = MeshNetworkManager.instance
    let network = MeshNetworkManager.instance.meshNetwork
    
    ///properties
    var subView : BasicControlsSubViewController? = nil
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "HHmm"
    }
    
    @IBAction func functionalitySwitch(_ sender: UISegmentedControl) {
        animateSubView()
    }
    
    func animateSubView(){
        UIView.animate(withDuration: 0.2, animations: {
            self.bTest.constant = -500
            self.view.layoutIfNeeded()
        }) { (Bool) in
            UIView.animate(withDuration: 0.3) {
                self.subView?.showHide()
                self.bTest.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "basicSegue"{
            let destination = segue.destination as! BasicControlsSubViewController
            subView = destination
            destination.scheduleDelegate = self
        }
    }
}
extension BubsSchedulerViewController: ScheduleData{
     func sendScheduleData(sceneId: UInt16?) {
        switch functionalitySegmentControl.selectedSegmentIndex {
        case 0:
            /// send on off action based off the index of the segmented controller
            let action = subView?.onOffSegmentView.selectedSegmentIndex == 0 ? 0x0 : 0x1
            sendMessage(action: UInt8(action), sceneId: nil)
        case 1:
            /// send schedule message based for the scene recall
            if sceneId == nil {
                showAlert(title: "No scene selected", message: "Please select a scene to recall. Or choose on or off.")
                return
            }
            sendMessage(action: UInt8(0x2), sceneId: sceneId)
        default:
            print("something went wrong")
        }
    }
    
    func sendMessage(action: UInt8, sceneId: UInt16?){

        ///year
        let year = 0x64
        ///month
        let month = 4095
        ///day
        let day = 0x00
        ///hour
        let hour = UInt8(dateFormatter.string(from: timePicker.date).prefix(2))
        ///minute
        let minute = UInt8(dateFormatter.string(from: timePicker.date).suffix(2))
        ///second
        let second = 0x00
        ///Day of Week
        var dayBinary = ""
        dayButtons.forEach { (b) in dayBinary.append(b.isOn ? "1" : "0")}
        let dayOfTheWeek = UInt8(dayBinary, radix: 2)!
        ///Action
        ///Transition Time
        ///Scene Number
        let sID = sceneId != nil ? sceneId : 0x0000
        
            let _ = try? manager.send(SchedulerActionSet(index: 0, year: UInt8(year), month: UInt16(month), day: UInt8(day), hour: hour!, minute: minute!, second: UInt8(second), dayOfWeek: UInt8(dayOfTheWeek), action: action, sceneID: sID!), to: (network?.groups[0])!, using: (network?.applicationKeys[0])!)
    }
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}
extension BubsSchedulerViewController: MeshNetworkDelegate{
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: Address) {
        switch message {
        case let status as SchedulerStatus:
            print(status)
            print("call back reached")
        default:
            print("call back not reached")
        }
    }
}
