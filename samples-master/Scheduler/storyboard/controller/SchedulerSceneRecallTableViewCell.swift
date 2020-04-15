//
//  SchedulerSceneRecallTableViewCell.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 11/26/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class SchedulerSceneRecallTableViewCell: UITableViewCell {

    @IBOutlet weak var sceneNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .gray
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

