//
//  ViewController.swift
//  CustomTableView
//
//  Created by Chris on 2018/4/11.
//  Copyright © 2018 chris. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Cell ID
    private final let cellIdentifier = "Cell"
    
    // Xib name
    private let xibName = "TableViewCell"
    
    var datas = ["Apple", "Banana", "Car", "Dog", "Elephant", "Frog", "Good", "Heaven", "Iron Man", "Joker",
                 "King", "Lion", "Man", "Nice", "Orange", "People", "Queen", "Race", "Seven", "Television",
                 "Universe", "Volume"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get xib
        let nib = UINib(nibName: xibName, bundle: nil)
        
        // Register
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // Manipulate datas
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get cell
        let tableCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TableViewCell
        
        // Set cell
        tableCell.cellImage.image = UIImage(named: datas[indexPath.row] as String)
        tableCell.cellLabel.text = datas[indexPath.row]
        
        return tableCell
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

