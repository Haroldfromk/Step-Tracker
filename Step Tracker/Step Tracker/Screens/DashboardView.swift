//
//  ContentView.swift
//  Step Tracker
//
//  Created by Dongik Song on 12/12/24.
//

import SwiftUI
import Charts

enum HealthMetricContext: CaseIterable, Identifiable {
    case steps, weight
    var id: Self { self }
    
    var title: String {
        switch self {
        case .steps: return "Steps"
        case .weight: return "Weight"
        }
    }
}

struct DashboardView: View {
    
    @Environment(HealthKitManager.self) private var hkManager
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming = false
    @State private var isShowingPermissionPrimingSheet = false
    @State private var selectedStat: HealthMetricContext = .steps
    
    var isSteps: Bool { selectedStat == .steps }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    Picker("Select Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) { metric in
                            Text(metric.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    StepBarChartView(selectedStat: selectedStat, chartData: hkManager.stepData)
                    
                    StepPieChartView(chartData: ChartMath.averageWeekdayCount(for: hkManager.stepData))
                }
            }
            .padding()
            .task {
                //                await hkManager.addSimulatorData()
                await hkManager.fetchStepCount()
                ChartMath.averageWeekdayCount(for: hkManager.stepData)
                //                await hkManager.fetchWeights()
                isShowingPermissionPrimingSheet = !hasSeenPermissionPriming
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionPrimingSheet, onDismiss: {
                // fetch health data
            }, content: {
                HealthKitPermissionPrimingView(hasSeen: $hasSeenPermissionPriming)
            })
        }
        .tint(isSteps ? .pink : .indigo)
    }
    

}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}