//
//  BSchedulerViewController.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 11/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

class BSchedulerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var setBtn: UIButton!
    @IBOutlet weak var plusBtn: UIBarButtonItem!
    
    var dataSource : [[Schedule]] = []
    var sectionHeaders = ["Active", "Inactive"]
        
    let groupMeshAddress : MeshAddress? = nil
    let model : Model? = nil
    var selectedSchedule : Schedule?
    @IBOutlet weak var groupOrAllSegmentController: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        setTableView(isSelectedGroups: true)
    }
    
    
    
    @IBAction func rangeSelected(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            setTableView(isSelectedGroups: true)
        case 1:
            setTableView(isSelectedGroups: false)
        default:
            print("Something went wrong.1")
        }

    }
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setTableView(isSelectedGroups: Bool){
        tableView.hideEmptyView()
        tableView.separatorStyle = .singleLine
        sectionHeaders = ["Active", "Inactive"]

        let schedules = MeshNetworkManager.instance.meshNetwork?.schedules
        if let ds = schedules{
            //gets active / deactive for all schedules
            if !isSelectedGroups{
                var activeSchedules: [Schedule] = []
                var inactiveSchedules: [Schedule] = []
                
                activeSchedules   = ds.filter({ ($0.isActive ?? false) })
                inactiveSchedules = ds.filter({ !($0.isActive ?? false) })
                dataSource = [activeSchedules, inactiveSchedules]
                groupOrAllSegmentController.selectedSegmentIndex = 1
            }else{
                //gets schedules for selected group
                var activeGroupSchedules : [Schedule] = []
                var inactiveGroups : [Schedule] = []
                
                let groupSchedules   = ds.filter({ $0.meshAddresses[0].address == MeshNetworkManager.instance.selectedConfigGroup?.address.address})
                activeGroupSchedules = groupSchedules.filter({ $0.isActive ?? false})
                inactiveGroups       = groupSchedules.filter({ !($0.isActive ?? false )})
                dataSource           =  [activeGroupSchedules, inactiveGroups]
                groupOrAllSegmentController.selectedSegmentIndex = 0
            }
        }        
        if dataSource.count == 2{
            if dataSource[0].count == 0 && dataSource[1].count == 0{
                tableView.setEmptyView(title: "Nothing Scheduled"
                    , message: "Press here to add one!"
                    , messageImage: UIImage(named: "add_btn") ?? UIImage())
                if let eView = self.view.viewWithTag(100){
                    let tapped = UITapGestureRecognizer(target: self, action: #selector(self.eTapped(_:)))
                    eView.addGestureRecognizer(tapped)
                }
                tableView.showEmptyView()
                tableView.separatorStyle = .none
                sectionHeaders = ["", ""]
            }
        }
        tableView.reloadData()
    }
    
    @objc func eTapped(_ sender: UITapGestureRecognizer? = nil) {
        self.performSegue(withIdentifier: "newSchedule", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CurrentScheduleTableViewCell
        let schedule =  dataSource[indexPath.section][indexPath.row]
        cell.nameLabel.text  = schedule.name
        cell.indexLabel.text = "\(indexPath.row + 1)"
        cell.setDaysLabel(dow: schedule.dayOfWeek)
        cell.setTimeLabel(hour: schedule.hour, minute: schedule.minute)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
        selectedSchedule = dataSource[indexPath.section][indexPath.row]
        performSegue(withIdentifier: "toSchedule", sender: cell)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "newSchedule"{
            //checks the number of schedules ~ doesnt perform segue if the there are more than 16 scheules
            //users will have to modify an existing one
            let currentCount = MeshNetworkManager.instance.meshNetwork?.schedules?.count
            if (currentCount ?? 0) + 1 > 16{
                let alert = UIAlertController(title: "Scheduler"
                    , message: "You have run out of available schedules for this scheduler. Please modify an existing one."
                    , preferredStyle: .alert)
                let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true)
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //
        if segue.identifier == "toSchedule"{
            if let destination = segue.destination as? SelectedScheduleViewController{
                destination.selectedSchedule = self.selectedSchedule
                destination.delegate = self
            }
        }else if segue.identifier == "newSchedule"{
            if let destination = segue.destination as? CreateScheduleViewController{
                 destination.delegate = self
             }
        }
    }
}
extension BSchedulerViewController : UpdateCurrentScheduleDelegate{
    func updateEdit(schedule: Schedule) {}
    
    
    func updateCurrents() {
        setTableView(isSelectedGroups: true)
    }
}
