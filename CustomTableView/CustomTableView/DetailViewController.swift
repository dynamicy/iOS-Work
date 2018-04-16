//
//  DetailViewController.swift
//  CustomTableView
//
//  Created by Chris on 2018/4/16.
//  Copyright © 2018 chris. All rights reserved.
//

import UIKit

class DetailViewController : UIViewController {
    
    @IBOutlet weak var cellLabel : UILabel!
    
    @IBOutlet weak var cellImageView : UIImageView!
    
    @IBOutlet weak var cellSwitch : UISwitch!
    
    var cellLabelText = ""
    
    var cellImage : UIImage? = nil
    
    var cellSwitchValue : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cellLabel.text = cellLabelText
        
        cellSwitch.isOn = cellSwitchValue
        
        cellImageView.image = UIImage(named: cellLabelText)
    
    }
}
