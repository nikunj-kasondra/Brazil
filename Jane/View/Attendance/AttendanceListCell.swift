//
//  AttendanceListCell.swift
//  Jane
//
//  Created by Rujal on 6/2/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit

class AttendanceListCell: UITableViewCell {

    @IBOutlet weak var lblPerform: UILabel!
    @IBOutlet weak var lblAttendance: UILabel!
    @IBOutlet weak var lblClass: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
