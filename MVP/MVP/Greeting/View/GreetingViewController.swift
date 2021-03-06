//
//  ViewController.swift
//  MVP
//
//  Created by Chris on 29/03/2018.
//  Copyright © 2018 chris. All rights reserved.
//

import UIKit
import Foundation

class GreetingViewController: UIViewController, GreetingView {

    @IBOutlet weak var firstNameTextField : UITextField?
    
    @IBOutlet weak var lastNameTextField : UITextField?
    
    @IBOutlet weak var greetingButton : UIButton?
    
    @IBAction func click(_ sender: UIButton!) {
        self.presenter?.showGreeting()
    }
    
    // Time delay
    private let timeDelay: Double = 1.0
    
    var presenter : GreetingPresenter? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = GreetingPresenter(view: self)
    }
    
    func showGreeting() {
        showAlert(msg: self.getFirstName() + " " + self.getLastName(), after: {})
    }
    
    func showAlert(msg: String, after:()->(Void)) {
        
        let alertController = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeDelay) {
            alertController.dismiss(animated: false, completion: nil)
        }
    }
    
    func getFirstName() -> String {
        return (self.firstNameTextField?.text)!
    }
    
    func getLastName() -> String {
        return (self.lastNameTextField?.text)!
    }
}

