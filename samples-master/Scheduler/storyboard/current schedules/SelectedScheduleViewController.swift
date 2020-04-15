//
//  SelectedScheduleViewController.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 11/30/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

class SelectedScheduleViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet var dayButtons: [BubsSchedulerWeekDayButton]!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var deactivateBtn: UIBarButtonItem!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet var views: [UIView]!
    
    var selectedSchedule: Schedule?
    var delegate : UpdateCurrentScheduleDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.backgroundColor  = .white
        editButton.tintColor    = ApplicationColors.color.primaryLight
        deactivateBtn.tintColor = ApplicationColors.color.primaryLight
        guard selectedSchedule != nil else { return }
        setValues(selectedSchedule: selectedSchedule!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.updateCurrents()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func setValues(selectedSchedule : Schedule){
        let bitHelper = BitAssistant()
        let d = selectedSchedule.dayOfWeek
        var b = bitHelper.bits(fromBytes: d)
        b.removeLast()
        b = b.reversed()
        for (i, bit) in b.enumerated(){
            dayButtons[i].activateButton(bool: Int(bit.rawValue) == 1)
            deactivateBtn.title = selectedSchedule.isActive! ? "Deactivate" : "Activate"
            editButton.isEnabled = selectedSchedule.isActive ?? false ? true : false
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "HH:mm"
            
            let date = dateFormatter.date(from: "\(selectedSchedule.hour):\(selectedSchedule.minute)")
            timePicker.date = date ?? Date()
        }
        
        navBar.topItem?.title = selectedSchedule.name
        
        switch selectedSchedule.action {
        case 0x0:
            actionLabel.text = "Turn Off"
        case 0x1:
            actionLabel.text = "Turn On"
        case 0x2:
            let scenes = MeshNetworkManager.instance.meshNetwork?.scenes
            
            let s = scenes?.filter({ $0.number == selectedSchedule.sceneID})
            if s?.count != 0{
                if let sScene = s?[0]{
                    actionLabel.text = "Scene Recall: \(sScene.name)"
                }
            }else{
                actionLabel.text = "Scene was deleted."
            }
            
        default:
            print("something went wrong with loading action")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEdit"{
            if let destination = segue.destination as? CreateScheduleViewController{
                destination.scheduleToEdit = selectedSchedule
                destination.delegate = self
            }
        }
    }

    @IBAction func editPressed(_ sender: Any) {
        performSegue(withIdentifier: "toEdit", sender: nil)

    }
    
    @IBAction func deactivatePressed(_ sender: UIBarButtonItem) {
        if selectedSchedule!.isActive!{
            let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to deactivte this schedule? It will no longer run.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes, I'm sure.", style: .default) { (action) in
                if let og = self.selectedSchedule{
                    self.selectedSchedule?.isActive = false
                    let _ = MeshNetworkManager.instance.save()

                    if let sG = MeshNetworkManager.instance.selectedConfigGroup{
                        let _ = try? MeshNetworkManager.instance.send(SchedulerActionSetUnacked(index: og.index
                            , year: og.year
                            , month: og.month
                            , day: og.day
                            , hour: og.hour
                            , minute: og.minute
                            , second: og.second
                            , dayOfWeek: og.dayOfWeek
                            , action: og.deactivatedAction
                            , transitionTime: TransitionTime(steps: og.transitionSteps ?? 0, stepResolution: StepResolution(rawValue: og.transitionResolution ?? 0) ?? StepResolution(rawValue: 0)!)
                            , sceneID: og.sceneID ?? 0x0000)
                            , to: sG
                            , using: (MeshNetworkManager.instance.meshNetwork?.applicationKeys[0])!)
                        
                        self.deactivateBtn.title = "Activate"
                        self.editButton.isEnabled = false

                    }
                }
                
            }
            let noAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(yesAction); alert.addAction(noAction)
            self.present(alert, animated: true)
        }else{
            ///activate
            let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to reactivate this schedule?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes, I'm sure.", style: .default) { (action) in
                if let og = self.selectedSchedule{
                      self.selectedSchedule?.isActive = true
                      let _ = MeshNetworkManager.instance.save()

                    if let sG = MeshNetworkManager.instance.selectedConfigGroup{
                        let _ = try? MeshNetworkManager.instance.send(SchedulerActionSetUnacked(index: og.index
                            , year: og.year
                            , month: og.month
                            , day: og.day
                            , hour: og.hour
                            , minute: og.minute
                            , second: og.second
                            , dayOfWeek: og.dayOfWeek
                            , action: og.action
                            , transitionTime: TransitionTime(steps: og.transitionSteps ?? 0, stepResolution: StepResolution(rawValue: og.transitionResolution ?? 0) ?? StepResolution(rawValue: 0)!)
                            , sceneID: og.sceneID ?? 0x0000)
                            , to: sG
                            , using: (MeshNetworkManager.instance.meshNetwork?.applicationKeys[0])!)
                        
                        self.deactivateBtn.title = "Deactivate"
                        self.editButton.isEnabled = true
                      }
                  }
                
            }
            let noAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(yesAction); alert.addAction(noAction)
            self.present(alert, animated: true)
        }
    }
}
extension SelectedScheduleViewController : UpdateCurrentScheduleDelegate {
    func updateEdit(schedule: Schedule) {
        let s = MeshNetworkManager.instance.meshNetwork?.schedules?.filter({ $0.index == schedule.index})
        selectedSchedule = s?[0]
        guard selectedSchedule != nil else {return}
        setValues(selectedSchedule: selectedSchedule!)
    }
    
    func updateCurrents() {}
}
