//
//  BubsSchedulerBasicCell.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 11/25/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class BubsSchedulerBasicCell : BubblyModelViewCell{
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var dayButtons: BubsSchedulerWeekDayButton!
    @IBOutlet weak var actionToggle: UISegmentedControl!
    
    @IBOutlet weak var setBtn: UIButton!
    @IBOutlet weak var barAnimationView: UIView!
    @IBOutlet weak var actionConstraint: NSLayoutConstraint!
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonPressedConstraint: NSLayoutConstraint!
    
    var cellController : SchedulerControllerTableViewCell? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.delegate = self
        tableView.dataSource = self
        setBtn.setTitleColor(ApplicationColors.color.primaryLight, for: .normal)
        
        tableView.register(UINib(nibName: "SchedulerDataControlNib", bundle: nil), forCellReuseIdentifier: "cell")
        barAnimationView.backgroundColor = ApplicationColors.color.primaryLight
    }
    
    
    @IBAction func setPressed(_ sender: Any) {
        cellController?.sendMessage()
        UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseOut, animations: {
            self.buttonPressedConstraint.constant = 0
            self.layoutIfNeeded()
        }) { (Bool) in
            UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut, animations: {
                self.buttonPressedConstraint.constant = 600
                self.layoutIfNeeded()
            }) { (Bool) in
                self.buttonPressedConstraint.constant = -600
            }
        }
    }
}
extension BubsSchedulerBasicCell : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 850
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SchedulerControllerTableViewCell
        cellController = cell
        cell.groupAddress = selectedGroupAddress
        return cell
    }
    
    func sendAnimation(){
        
    }
}
