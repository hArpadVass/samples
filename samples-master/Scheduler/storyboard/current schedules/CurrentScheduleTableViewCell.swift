//
//  CurrentScheduleTableViewCell.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 11/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class CurrentScheduleTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var timeLabel : UILabel!
    @IBOutlet weak var daysRun   : UILabel!
    
    let days = ["M.","Tu.","W.","Th.","F.","S.","Su."]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDaysLabel(dow: UInt8){
        var text = "Days set to run: "
        var array = BitAssistant.init().bits(fromBytes: dow)
        array = array.dropLast()
        for (i, bit) in array.enumerated(){
            if bit.description == "1"{
                text.append("\(days[i]) ")
            }
        }
        daysRun.text = text
    }
    
    func setTimeLabel(hour: UInt8, minute: UInt8){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        
        let date = dateFormatter.date(from: "\(hour):\(minute)")
    }
}
