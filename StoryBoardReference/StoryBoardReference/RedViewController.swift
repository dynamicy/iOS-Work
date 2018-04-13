//
//  RedViewController.swift
//  StoryBoardReference
//
//  Created by Chris on 2018/4/13.
//  Copyright © 2018 chris. All rights reserved.
//

import UIKit

class RedViewController: UIViewController {
    
    private let segueIdeitifer = "toBlue"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdeitifer {
            guard let controller = segue.destination as? BlueViewController else {
                return
            }
        }
    }
}

