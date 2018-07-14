//
//  KeysCell.swift
//  Jane
//
//  Created by Rujal on 6/5/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit

class KeysCell: UITableViewCell {
    
    @IBOutlet weak var imgPay: UIImageView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblSub: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
