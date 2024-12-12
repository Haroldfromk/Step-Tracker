//
//  Step_TrackerApp.swift
//  Step Tracker
//
//  Created by Dongik Song on 12/12/24.
//

import SwiftUI

@main
struct Step_TrackerApp: App {
    
    let hkManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(hkManager)
        }
    }
}
