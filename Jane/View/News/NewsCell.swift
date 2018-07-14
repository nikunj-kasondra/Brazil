//
//  NewsCell.swift
//  Jane
//
//  Created by Rujal on 7/1/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {

    @IBOutlet weak var btnImage: UIButton!
    @IBOutlet weak var btnTitle: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var participateHeight: NSLayoutConstraint!
    @IBOutlet weak var lblDesc1: UILabel!
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var lblDate1: UILabel!
    @IBOutlet weak var lblAuthor1: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var sideView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
