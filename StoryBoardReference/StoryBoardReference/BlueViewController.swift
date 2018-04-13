//
//  BlueViewController.swift
//  StoryBoardReference
//
//  Created by Chris on 2018/4/13.
//  Copyright © 2018 chris. All rights reserved.
//

import UIKit

class BlueViewController : UIViewController {
    
    @IBAction func backAction(_ sender: Any) {
        if (navigationController?.viewControllers[0] as? RedViewController) != nil {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
