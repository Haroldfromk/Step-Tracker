//
//  ChartDataTypes.swift
//  Step Tracker
//
//  Created by Dongik Song on 12/15/24.
//

import Foundation

struct WeekdayChartData: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double
}
