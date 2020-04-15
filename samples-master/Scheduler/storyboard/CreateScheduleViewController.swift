//
//  CreateScheduleViewController.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 11/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

class CreateScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var cellController : SchedulerControllerTableViewCell? = nil
    
    @IBOutlet weak var tableView: UITableView!
    let groupMeshAddress : MeshAddress? = nil
    var delegate         : UpdateCurrentScheduleDelegate?
    var scheduleToEdit   : Schedule?
    var sceneDelegate    : AddSceneFromSchedulerDelegate?
    @IBOutlet weak var navController: UINavigationBar!
    
    var advancedTimeChosenDelegate : AdvancedSettingsChosenDelegate?

    let model : Model? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SchedulerDataControlNib", bundle: nil), forCellReuseIdentifier: "cell")
        
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if scheduleToEdit != nil{
            delegate?.updateEdit(schedule: scheduleToEdit!)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 800
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //todo : more data
        return 1
    }
    @IBAction func savePressed(_ sender: UIButton) {
        cellController?.sendMessage()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SchedulerControllerTableViewCell
        cellController = cell
        cell.delegate = self
        cell.advancedBtnDelegate = self
        cell.scheduleToEdit = self.scheduleToEdit
        
        if let sE = scheduleToEdit{
            let bitHelper = BitAssistant()
            navController.topItem?.title = sE.name
            cell.nameTextField.text = sE.name
            var b = bitHelper.bits(fromBytes: sE.dayOfWeek)
            b.removeLast()
            b = b.reversed()
            for (i, bit) in b.enumerated(){
                cell.dayButtons[i].activateButton(bool: Int(bit.rawValue) == 1)
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "HH:mm"

            let date = dateFormatter.date(from: "\(sE.hour):\(sE.minute)")
            cell.timePicker.date = date ?? Date()
            
            switch sE.action {
            case 0x0:
                cell.actionSegment.selectedSegmentIndex      = 0
                cell.onOffActionSegment.selectedSegmentIndex = 1
            case 0x1:
                cell.actionSegment.selectedSegmentIndex      = 0
                cell.onOffActionSegment.selectedSegmentIndex = 0
            case 0x2:
                ///get selected scene and highlight in cell
                cell.actionSegment.selectedSegmentIndex = 1
                cell.animateActionView(segment: 1)
                let scenes = MeshNetworkManager.instance.meshNetwork?.scenes
                if let selectedScene = scenes?.filter({$0.number == sE.sceneID}){
                    if selectedScene.count != 0{
                        let index = scenes?.firstIndex(of: (selectedScene[0])) ?? 0
                        cell.selectedScene = selectedScene[0]
                        cell.sceneRecallTableView.selectRow(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .top)
                    }
                }

            default:
                print("something went wrong")
            }
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAdvanced"{
            if let destination = segue.destination as? SchedulerModalViewController{
                destination.advancedTimeChosenDelegate = self.advancedTimeChosenDelegate
            }
        }else if segue.identifier == "toScenes"{
            if let destination = segue.destination as? AddSceneModalViewController{
                destination.sceneDelegate = sceneDelegate
            }

        }
    }
}
extension CreateScheduleViewController : NewScheduleDelegate{
    func alert(title: String, message: String, shouldDismiss: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if shouldDismiss{
            let action = UIAlertAction(title: "Okay", style: .default) { (UIAlertAction) in
                self.delegate?.updateCurrents()
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(action)
        }else{
            let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
        
    }
}
extension CreateScheduleViewController : ScheduleAdvancedDelegate{
    func addSceneBtnPressed(sceneDelegate: AddSceneFromSchedulerDelegate) {
        self.sceneDelegate = sceneDelegate
        self.performSegue(withIdentifier: "toScenes", sender: nil)
    }
    
    func btnPressed(advancedTimeChosenDelegate: AdvancedSettingsChosenDelegate) {
        self.advancedTimeChosenDelegate = advancedTimeChosenDelegate
        self.performSegue(withIdentifier: "toAdvanced", sender: nil)

    }
}

protocol UpdateCurrentScheduleDelegate {
    func updateCurrents()
    func updateEdit(schedule: Schedule)
}

protocol AddSceneFromSchedulerDelegate {
    func sceneAdded()
    func dismissView()
}
