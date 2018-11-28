//
//  DefaultEvent.swift
//  DragItems
//
//  Created by Chris on 2018/11/28.
//

import Foundation
import JZCalendarWeekView

class DefaultEvent: JZBaseEvent {
    
    var location: String
    var title: String
    
    
    init(id: String, title: String, startDate: Date, endDate: Date, location: String) {
        self.location = location
        self.title = title
                
        super.init(id: id, startDate: startDate, endDate: endDate)
    }
    
    override func copy(with zone: NSZone?) -> Any {
        return DefaultEvent(id: id, title: title, startDate: startDate, endDate: endDate, location: location)
    }
}
