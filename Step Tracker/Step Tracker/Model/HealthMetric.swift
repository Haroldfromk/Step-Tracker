//
//  HealthMetric.swift
//  Step Tracker
//
//  Created by Dongik Song on 12/14/24.
//

import Foundation

struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
