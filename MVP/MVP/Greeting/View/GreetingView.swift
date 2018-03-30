//
//  GreetingView.swift
//  MVP
//
//  Created by Chris on 29/03/2018.
//  Copyright © 2018 chris. All rights reserved.
//

import Foundation

protocol GreetingView {
    
    func showGreeting()
    
    func showAlert(msg: String, after:()->(Void))
    
    func getFirstName() -> String
    
    func getLastName() -> String
}
