//
//  MultiNetworkTableViewCell.swift
//  nRFMeshProvision_Example
//
//  Created by Hayden Vass on 3/31/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

class MultiNetworkTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nodesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setlabels(source : BubblySupplimentalNetwork){
        nameLabel.text = source.networkName
        nodesLabel.text = "Nodes : \(source.numNodes)"
        descriptionLabel.text = "todo"
    }
}
