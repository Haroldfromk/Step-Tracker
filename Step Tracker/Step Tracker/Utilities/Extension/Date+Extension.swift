//
//  Date+Extension.swift
//  Step Tracker
//
//  Created by Dongik Song on 12/15/24.
//

import Foundation

extension Date {
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    var weekdayTitle: String {
        self.formatted(.dateTime.weekday(.wide))
    }
}
