//
//  DateFormat.swift
//  Jane
//
//  Created by Rujal on 6/24/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit

class DateFormat: NSObject {
    static func getDay(dateStr: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let date = dateFormatter.date(from: dateStr)
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date!)
        return String(day)
    }
    static func getTime(dateStr: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let date = dateFormatter.date(from: dateStr)
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: date!)
        return time
    }
    static func getTime1(dateStr: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmmss"
        let date = dateFormatter.date(from: dateStr)
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: date!)
        return time
    }
    static func getWeek(dateStr: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let date = dateFormatter.date(from: dateStr)
        let weekStr = Calendar.current.component(.weekday, from: date!)
        return weekStr
    }
    
    
}
