//
//  TableViewCell.swift
//  CustomTableView
//
//  Created by Chris on 2018/4/11.
//  Copyright © 2018 chris. All rights reserved.
//

import UIKit

class TableViewCell : UITableViewCell {

    @IBOutlet weak var cellImage : UIImageView!
    
    @IBOutlet weak var cellLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
