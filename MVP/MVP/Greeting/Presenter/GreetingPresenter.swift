//
//  GreetingPresenter.swift
//  MVP
//
//  Created by Chris Huang 黃信文 (奧圖碼) on 29/03/2018.
//  Copyright © 2018 chris. All rights reserved.
//

import Foundation

protocol GreetingPresenter {
    
    func showGreeting()
    
    init(view: GreetingView, person: Person)
}
