//
//  AllDayEvent.swift
//  DragItems
//
//  Created by Chris on 2018/11/28.
//

import JZCalendarWeekView

class AllDayEvent: JZAllDayEvent {
    
    var location: String
    var title: String
    
    
    init(id: String, title: String, startDate: Date, endDate: Date, location: String, isAllDay: Bool) {
        self.location = location
        self.title = title
                
        super.init(id: id, startDate: startDate, endDate: endDate, isAllDay: isAllDay)
    }
    
    override func copy(with zone: NSZone?) -> Any {
        return AllDayEvent(id: id, title: title, startDate: startDate, endDate: endDate, location: location, isAllDay: isAllDay)
    }
}
