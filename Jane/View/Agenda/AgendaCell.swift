//
//  AgendaCell.swift
//  Jane
//
//  Created by Rujal on 6/23/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit

class AgendaCell: UITableViewCell {

    @IBOutlet weak var descTop: NSLayoutConstraint!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateBottom: NSLayoutConstraint!
    @IBOutlet weak var dateWidth: NSLayoutConstraint!
    @IBOutlet weak var dateHeight: NSLayoutConstraint!
    @IBOutlet weak var dateLead: NSLayoutConstraint!
    @IBOutlet weak var learnerColor: UIView!
    @IBOutlet weak var imgPresent: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblWeek: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
