//
//  ViewController.swift
//  CustomTableView
//
//  Created by Chris on 2018/4/16.
//  Copyright © 2018 chris. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    // Cell ID
    private final let cellIdentifier = "Cell"
    
    // Segue ID
    private let segueIdentifier = "showDetail"
    
    var datas = ["Apple", "Banana", "Car", "Dog", "Elephant", "Frog", "Good", "Heaven", "Iron Man", "Joker",
                 "King", "Lion", "Man", "Nice", "Orange", "People", "Queen", "Race", "Seven", "Television",
                 "Universe", "Volume"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Manipulate datas
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get cell
        let tableCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TableViewCell
        
        // Set cell
        tableCell.cellImage.image = UIImage(named: datas[indexPath.row] as String)
        tableCell.cellLabel.text = datas[indexPath.row]
        tableCell.cellSwitch.isOn = true
        
        return tableCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            if let indexPath = tableView.indexPathForSelectedRow {
                // Getting the current cell from the index path
                let currentCell = tableView.cellForRow(at: indexPath)! as! TableViewCell
                let controller = segue.destination as! DetailViewController
                controller.cellLabelText = currentCell.cellLabel.text!
                controller.cellSwitchValue = currentCell.cellSwitch.isOn
                present(controller, animated: true, completion: nil)
            }
        }
    }
}

