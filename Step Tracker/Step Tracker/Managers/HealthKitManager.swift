//
//  HealthKitManager.swift
//  Step Tracker
//
//  Created by Dongik Song on 12/12/24.
//

import Foundation
import HealthKit
import Observation

@Observable class HealthKitManager {
    
    let store = HKHealthStore()
    
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
    
    var stepData: [HealthMetric] = []
    var weightData: [HealthMetric] = []
    var weightDiffData: [HealthMetric] = []
    
    func addSimulatorData() async {
        var mockSamples: [HKQuantitySample] = []
        
        for i in 0..<28 {
            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4_000...20_000))
            let weightQuantity = HKQuantity(unit: .pound(), doubleValue: .random(in: (160 + Double(i/3)...165 + Double(i/3))))
            
            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
            let endDate = Calendar.current.date(byAdding: .day, value: 0, to: startDate)!
            let stepSample = HKQuantitySample(
                type: HKQuantityType(.stepCount),
                quantity: stepQuantity,
                start: startDate,
                end: endDate
            )
            let weightSample = HKQuantitySample(
                type: HKQuantityType(.bodyMass),
                quantity: weightQuantity,
                start: startDate,
                end: endDate
            )
            
            mockSamples.append(stepSample)
            mockSamples.append(weightSample)
        }
        
        try! await store.save(mockSamples)
        
        print("✅ Dummy Data sent up")
    }
    
    func fetchStepCount() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: queryPredicate)
        
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate,
                                                               options: .cumulativeSum,
                                                               anchorDate: endDate,
                                                               intervalComponents: .init(day: 1)
        )
        
        do {
            let stepsCounts = try! await stepsQuery.result(for: store)
            stepData = stepsCounts.statistics().map({
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            })
        } catch {
            
        }
        
    }
    
    func fetchWeights() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate: queryPredicate)
        
        let weightQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate,
                                                                options: .mostRecent,
                                                                anchorDate: endDate,
                                                                intervalComponents: .init(day: 1)
        )
        
        do {
            let weights = try! await weightQuery.result(for: store)
            weightData = weights.statistics().map({
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
            })
        } catch {
            
        }
        
    }
    
    func fetchWeightsForDifferentials() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -29, to: endDate)
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate: queryPredicate)
        
        let weightQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate,
                                                                options: .mostRecent,
                                                                anchorDate: endDate,
                                                                intervalComponents: .init(day: 1)
        )
        
        do {
            let weights = try! await weightQuery.result(for: store)
            weightDiffData = weights.statistics().map({
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
            })
        } catch {
            
        }
        
    }
    
    func addStepData(for date: Date, value: Double) async {
        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let stepSample = HKQuantitySample(
            type: HKQuantityType(.stepCount),
            quantity: stepQuantity,
            start: date,
            end: date
        )
        
        try! await store.save(stepSample)
    }
    
    func addWeightData(for date: Date, value: Double) async {
        let weightQuantity = HKQuantity(unit: .pound(), doubleValue: value)
        let weightSample = HKQuantitySample(
            type: HKQuantityType(.bodyMass),
            quantity: weightQuantity,
            start: date,
            end: date
        )
        
        try! await store.save(weightSample)
    }
    
    //    func fetchStepCountDummy() async {
    //        // Create a predicate for this week's samples.
    //        let calendar = Calendar(identifier: .gregorian)
    //        let today = calendar.startOfDay(for: Date())
    //
    //
    //        guard let endDate = calendar.date(byAdding: .day, value: 1, to: today) else {
    //            fatalError("*** Unable to calculate the end time ***")
    //        }
    //
    //
    //        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else {
    //            fatalError("*** Unable to calculate the start time ***")
    //        }
    //
    //
    //        let thisWeek = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
    //
    //
    //        // Create the query descriptor.
    //        let stepType = HKQuantityType(.stepCount)
    //        let stepsThisWeek = HKSamplePredicate.quantitySample(type: stepType, predicate:thisWeek)
    //        let everyDay = DateComponents(day:1)
    //
    //
    //        let sumOfStepsQuery = HKStatisticsCollectionQueryDescriptor(
    //            predicate: stepsThisWeek,
    //            options: .cumulativeSum,
    //            anchorDate: endDate,
    //            intervalComponents: everyDay)
    //
    //
    //        let stepCounts = try await sumOfStepsQuery.result(for: store)
    //
    //
    //        // Use the statistics collection here.
    //    }
    
}
