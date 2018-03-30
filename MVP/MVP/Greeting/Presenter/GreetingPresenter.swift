//
//  GreetingPresenter.swift
//  MVP
//
//  Created by Chris on 29/03/2018.
//  Copyright © 2018 chris. All rights reserved.
//

import Foundation

class GreetingPresenter {
    
    let view: GreetingView
    
    required init(view: GreetingView) {
        self.view = view
    }
    
    func showGreeting() {
        view.showGreeting()
    }
}
