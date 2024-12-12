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
    
}
