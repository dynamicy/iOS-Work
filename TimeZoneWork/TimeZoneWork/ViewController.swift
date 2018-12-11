//
//  ViewController.swift
//  TimeZoneWork
//
//  Created by Chris on 2018/12/11.
//  Copyright © 2018 Chris. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let utcDate = Date().toGlobalTime()
        let localDate = utcDate.toLocalTime()
        
        var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
        var localTimeZoneName: String { return TimeZone.current.identifier }
        var timeZoneAbbreviations: [String:String] { return TimeZone.abbreviationDictionary }
        var timeZoneIdentifiers: [String] { return TimeZone.knownTimeZoneIdentifiers }
        
        print("utcDate - \(utcDate)")
        print("localDate - \(localDate)")
        print("localTimeZoneAbbreviation - \(localTimeZoneAbbreviation)")
        print("localTimeZoneName - \(localTimeZoneName)")
//        print("timeZoneAbbreviations - \(timeZoneAbbreviations)")
//        print("timeZoneIdentifiers - \(timeZoneIdentifiers)")
        
//        for item in timeZoneIdentifiers {
//            print("\(item.)")
//        }
    }
}

