//
//  Array+Extension.swift
//  Step Tracker
//
//  Created by Dongik Song on 12/17/24.
//

import Foundation

extension Array where Element == Double {
    var average: Double {
        guard !self.isEmpty else { return 0 }
        let total = self.reduce(0, +)
        return total/Double(self.count)
    }
}
