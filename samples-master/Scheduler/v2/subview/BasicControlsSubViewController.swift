//
//  BasicControlsSubViewController.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 11/18/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

class BasicControlsSubViewController: UIViewController {
    
    var dataSet = MeshNetworkManager.instance.meshNetwork?.scenes
    var isOnOff = false
    var scheduleDelegate : ScheduleData? = nil
    
    ///outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var onOffSegmentView: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        tableView.setEmptyView(title: "No Scenes", message: "You currently have no scenes set up.", messageImage: UIImage())
        dataSet?.count == 0 ? tableView.showEmptyView() : tableView.hideEmptyView()
        tableView.separatorStyle = dataSet?.count == 0 ? .none : .singleLine
    }
    
    @IBAction func setButtonPressed(_ sender: Any) {
        if tableView.indexPathForSelectedRow != nil{
            scheduleDelegate?.sendScheduleData(sceneId: dataSet?[tableView.indexPathForSelectedRow!.row].number)
        }else{
            scheduleDelegate?.sendScheduleData(sceneId: nil)
        }
    }

    func showHide(){
        tableView.isHidden = !tableView.isHidden
        onOffSegmentView.isHidden = !onOffSegmentView.isHidden
    }
}
extension BasicControlsSubViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSet?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell1") as! SchedulerBasicTableViewCell
        cell.nameLabel.text = dataSet?[indexPath.row].name
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select which scene to apply."
    }
}

protocol ScheduleData {
    func sendScheduleData(sceneId : UInt16?)
}

