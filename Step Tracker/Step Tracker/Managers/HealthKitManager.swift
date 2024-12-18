//
//  HealthKitManager.swift
//  Step Tracker
//
//  Created by Dongik Song on 12/12/24.
//

import Foundation
import HealthKit
import Observation

@Observable
@MainActor
class HealthKitData {
    var stepData: [HealthMetric] = []
    var weightData: [HealthMetric] = []
    var weightDiffData: [HealthMetric] = []
}


@Observable
final class HealthKitManager: Sendable {
    
    let store = HKHealthStore()
    
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
    
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
    
    
    /// Fetch last 28days of step count from HealthKit
    /// - Returns: Array of ``HealthMetric``
    func fetchStepCount() async throws -> [HealthMetric] {
        guard store.authorizationStatus(for: HKQuantityType(.stepCount)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: 28)
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: queryPredicate)
        
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate,
                                                               options: .cumulativeSum,
                                                               anchorDate: interval.end,
                                                               intervalComponents: .init(day: 1)
        )
        
        do {
            let stepsCounts = try await stepsQuery.result(for: store)
            return stepsCounts.statistics().map({
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            })
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unableToCompleteRequest
        }
        
    }
    
    
    /// Fetch most recent weight sample on each day for a specified number of days back from today
    /// - Parameter daysBack: Days back from today. Ex - 28 will return the last 28days.
    /// - Returns: Array of ``HealthMetric``
    func fetchWeights(daysBack: Int) async throws -> [HealthMetric] {
        guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: daysBack)
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate: queryPredicate)
        
        let weightQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate,
                                                                options: .mostRecent,
                                                                anchorDate: interval.end,
                                                                intervalComponents: .init(day: 1)
        )
        
        do {
            let weights = try await weightQuery.result(for: store)
            return weights.statistics().map({
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
            })
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unableToCompleteRequest
        }
        
    }
    
    
    /// Write step count data to HealthKit. Requires HealthKit write permission
    /// - Parameters:
    ///   - date: Date for step count value
    ///   - value: Step count value
    func addStepData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.stepCount))
        
        switch status {
            
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "step count")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        
        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let stepSample = HKQuantitySample(
            type: HKQuantityType(.stepCount),
            quantity: stepQuantity,
            start: date,
            end: date
        )
        
        do {
            try await store.save(stepSample)
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    
    /// Writes the weight value to HealthKit. Requires HealthKit write permission.
    ///
    /// This asynchronous function records a weight value into HealthKit.
    /// Use `try await` when calling this function to handle its asynchronous behavior.
    ///
    /// - Parameters:
    ///   - date: The date associated with the weight value.
    ///   - value: The weight value in pounds. Represented as a `Double` for `.bodyMass` conversions.
    /// - Throws: `HealthKitError` if the write operation fails.
    /// - Note: Ensure HealthKit write permission is granted before calling this method.
    func addWeightData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.bodyMass))
        
        switch status {
            
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "weight")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        
        let weightQuantity = HKQuantity(unit: .pound(), doubleValue: value)
        let weightSample = HKQuantitySample(
            type: HKQuantityType(.bodyMass),
            quantity: weightQuantity,
            start: date,
            end: date
        )
        
        do {
            try await store.save(weightSample)
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    
    /// Creates a Dateinterval between two dates
    /// - Parameters:
    ///   - date: End of date interval. Ex - today
    ///   - daysBack: Start of date interval. Ex - 28 days ago
    /// - Returns: Date range between two dates as a DateInterval
    private func createDateInterval(from date: Date, daysBack: Int) -> DateInterval {
        let calendar = Calendar.current
        let startOfEndDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startOfEndDate)!
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: endDate)!
        return .init(start: startDate, end: endDate)
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
