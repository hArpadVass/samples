//
//  SubnetTableViewCell.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 1/7/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class SubnetTableViewCell: UITableViewCell {
    @IBOutlet weak var networkName: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
