//
//  FilterCell.swift
//  Yelp
//
//  Created by Pooja Chowdhary on 4/7/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FilterCellDelegate {
    @objc optional func filterCell(filterCell: FilterCell, didChangeValue value: Bool)
}

class FilterCell: UITableViewCell {
    
    weak var delegate: FilterCellDelegate?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    
    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        delegate?.filterCell?(filterCell: self, didChangeValue: onSwitch.isOn)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
