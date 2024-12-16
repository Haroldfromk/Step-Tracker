//
//  ChartMath.swift
//  Step Tracker
//
//  Created by Dongik Song on 12/15/24.
//

import Foundation
import Algorithms

struct ChartMath {
    
    static func averageWeekdayCount(for metric: [HealthMetric]) -> [WeekdayChartData] {
        let sortedByWeekday = metric.sorted { $0.date.weekdayInt < $1.date.weekdayInt }
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }
        
        var weekdayChartData: [WeekdayChartData] = []
        
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgSteps = total/Double(array.count)
            
            weekdayChartData.append(.init(date: firstValue.date, value: avgSteps))
        }
        
        //        for metric in sortedByWeekday {
        //            print("Day: \(metric.date.weekdayInt), value: \(metric.value)")
        //        }
        //
        //        print("----")
        //
        //        for day in weekdayChartData {
        //            print("Day: \(day.date.weekdayInt), value: \(day.value)")
        //        }
        
        return weekdayChartData
    }
    
    static func averageDailyWeightDiffs(for weights: [HealthMetric]) -> [WeekdayChartData] {
        var diffValues: [(date: Date, value: Double)] = []
        var weekdayChartData: [WeekdayChartData] = []
        
        for i in 1 ..< weights.count {
            let date = weights[i].date
            let diff = weights[i].value - weights[i-1].value
            diffValues.append((date: date, value: diff))
        }
        
        let sortedByWeekday = diffValues.sorted { $0.date.weekdayInt < $1.date.weekdayInt }
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }
        
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgSteps = total/Double(array.count)
            
            weekdayChartData.append(.init(date: firstValue.date, value: avgSteps))
        }
        
        for value in diffValues {
            print("\(value.date), \(value.value)")
        }
        
        for array in weekdayArray {
            print("-----")
            for day in array{
                print("\(day.date.weekdayInt), \(day.value)")
            }
        }
        
        for data in weekdayChartData {
            print("\(data.date.weekdayInt), \(data.value)")
        }
        
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

