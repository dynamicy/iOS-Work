//
//  ViewController.swift
//  CustomTableView
//
//  Created by Chris on 2018/4/11.
//  Copyright © 2018 chris. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Image name
    private final let imageName = "restaurant"
    
    // Cell ID
    private final let cellIdentifier = "Cell"
    
    var datas = ["Apple", "Banana", "Car", "Dog", "Elephant", "Frog", "Good", "Heaven", "Iron Man", "Joker",
                 "King", "Lion", "Man", "Nice", "Orange", "People", "Queen"]
    
    // Manipulate datas
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get cell
        let tableCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // Set cell
        tableCell.textLabel?.text = datas[indexPath.row]
        tableCell.imageView?.image = UIImage(named: imageName)
        
        return tableCell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

