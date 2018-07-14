//
//  ListCell.swift
//  Jane
//
//  Created by Rujal on 6/3/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {
    @IBOutlet weak var imgStudentImage: UIImageView!
    @IBOutlet weak var lblStudentName: UILabel!
    
    @IBOutlet weak var imgCheck: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
