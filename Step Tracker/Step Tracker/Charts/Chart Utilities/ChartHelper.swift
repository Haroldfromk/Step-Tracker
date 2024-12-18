//
//  ChartHelper.swift
//  Step Tracker
//
//  Created by Dongik Song on 12/17/24.
//

import Foundation
import Algorithms

struct ChartHelper {
    
    static func convert(data: [HealthMetric]) -> [DateValueChartData] {
        data.map { .init(date: $0.date, value: $0.value) }
    }
    
    
    static func parseSelectedData(from data: [DateValueChartData], in selectedDate: Date?) -> DateValueChartData? {
        guard let selectedDate else { return nil }
        return data.first {
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        }
    }
    
    static func averageWeekdayCount(for metric: [HealthMetric]) -> [DateValueChartData] {
        //let sortedByWeekday = metric.sorted { $0.date.weekdayInt < $1.date.weekdayInt }
        let sortedByWeekday = metric.sorted(using: KeyPathComparator(\.date.weekdayInt))
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }
        
        var weekdayChartData: [DateValueChartData] = []
        
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgSteps = total/Double(array.count)
            
            weekdayChartData.append(.init(date: firstValue.date, value: avgSteps))
        }
        
        return weekdayChartData
    }
    
    static func averageDailyWeightDiffs(for weights: [HealthMetric]) -> [DateValueChartData] {
        var diffValues: [(date: Date, value: Double)] = []
        var weekdayChartData: [DateValueChartData] = []
        
        guard weights.count > 1 else { return [] }
        
        for i in 1 ..< weights.count {
            let date = weights[i].date
            let diff = weights[i].value - weights[i-1].value
            diffValues.append((date: date, value: diff))
        }
        
        let sortedByWeekday = diffValues.sorted(using: KeyPathComparator(\.date.weekdayInt))
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }
        
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgSteps = total/Double(array.count)
            
            weekdayChartData.append(.init(date: firstValue.date, value: avgSteps))
        }
        
//        for value in diffValues {
//            print("\(value.date), \(value.value)")
//        }
//
//        for array in weekdayArray {
//            print("-----")
//            for day in array{
//                print("\(day.date.weekdayInt), \(day.value)")
//            }
//        }
//
//        for data in weekdayChartData {
//            print("\(data.date.weekdayInt), \(data.value)")
//        }
        
        return weekdayChartData
    }
    
    
    //    static func averageDailyWeightDiffs(for weights: [HealthMetric]) -> [WeekdayChartData] {
    //        var diffValues: [(date: Date, value: Double)] = []
    //        var weekdayChartData: [WeekdayChartData] = []
    //
    //        for i in 0..<weights.count {
    //            if i == 0 {
    //                diffValues.append((date: weights[i].date, value: 0))
    //            } else {
    //                let date = weights[i].date
    //                let diff = weights[i].value - weights[i-1].value
    //                diffValues.append((date: date, value: diff))
    //            }
    //        }
    //
    //        let sortedByWeekday = diffValues.sorted { $0.date.weekdayInt < $1.date.weekdayInt }
    //        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }
    //
    //        for array in weekdayArray {
    //            guard let firstValue = array.first else { continue }
    //            let total = array.reduce(0) { $0 + $1.value }
    //            let avgSteps = total/Double(array.count)
    //
    //            weekdayChartData.append(.init(date: firstValue.date, value: avgSteps))
    //        }
    //
    ////        for value in diffValues {
    ////            print("\(value.date), \(value.value)")
    ////        }
    ////
    ////        for array in weekdayArray {
    ////            print("-----")
    ////            for day in array{
    ////                print("\(day.date.weekdayInt), \(day.value)")
    ////            }
    ////        }
    ////
    ////        for data in weekdayChartData {
    ////            print("\(data.date.weekdayInt), \(data.value)")
    ////        }
    //
    //        return weekdayChartData
    //    }
}
