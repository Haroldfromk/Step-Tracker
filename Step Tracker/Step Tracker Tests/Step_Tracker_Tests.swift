//
//  Step_Tracker_Tests.swift
//  Step Tracker Tests
//
//  Created by Dongik Song on 12/18/24.
//

import Testing
import Foundation
@testable import Step_Tracker

struct Step_Tracker_Tests {

    @Test func arrayAverage() {
        let array: [Double] = [2.0, 3.1, 0.45, 1.84]
        #expect(array.average ==  1.8475)
    }

}

@Suite("Chart Helper Tests") struct ChartHelperTests {
    
    var metrics: [HealthMetric] = [
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 12, day: 2))!, value: 1000), // Mon
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 12, day: 3))!, value: 500), // Tue
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 12, day: 4))!, value: 250), // Wed
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 12, day: 9))!, value: 750), // Mon
    ]
    
    @Test func averageWeekdayCount() {
        let averageWeekdayCount = ChartHelper.averageWeekdayCount(for: metrics)
        #expect(averageWeekdayCount.count == 3)
        #expect(averageWeekdayCount[0].value == 875)
        #expect(averageWeekdayCount[1].value == 500)
        #expect(averageWeekdayCount[2].date.weekdayTitle == "Wednesday")
    }
}
