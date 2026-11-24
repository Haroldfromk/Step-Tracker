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
    @Environment(HealthKitData.self) private var hkData
    @State private var isShowingPermissionPrimingSheet = false
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var isShowingAlert = false
    @State private var fetchError: STError = .noData
    
    //var isSteps: Bool { selectedStat == .steps }
    var metricColor: Color {
        selectedStat == .steps ? .pink : .indigo
    }
    
    var navbarTint: Color {
        if #available(iOS 26, *) {
            return .primary
        } else {
            return metricColor
        }
    }

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
                    
                    switch selectedStat {
                    case .steps:
                        StepBarChartView(chartData: ChartHelper.convert(data: hkData.stepData))
                        
                        StepPieChartView(chartData: ChartHelper.averageWeekdayCount(for: hkData.stepData))
                    case .weight:
                        WeightLineChartView(chartData: ChartHelper.convert(data: hkData.weightData))
                        WeightDiffBarChartView(chartData: ChartHelper.averageDailyWeightDiffs(for: hkData.weightDiffData))
                    }
                }
                .padding()
            }
            .task {
                //await hkManager.addSimulatorData()
                fetchHealthData()
            }
            .navigationTitle("Dashboard")
            .toolbarTitleDisplayMode(.inlineLarge)
            .background(LinearGradient(colors: [metricColor.opacity(0.25), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(isShowingPermissionPriming: $isShowingPermissionPrimingSheet, metric: metric)
            }
            .fullScreenCover(isPresented: $isShowingPermissionPrimingSheet, onDismiss: {
                fetchHealthData()
            }, content: {
                HealthKitPermissionPrimingView()
            })
            .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
                // action
                
            } message: { fetchError in
                Text(fetchError.failureReason)
            }
            .toolbar {
                if #available(iOS 26, *) {
                    if DataAnalyzer.shared.model.isAvailable {
                        Button("Analyze Data", systemImage: "apple.intelligence") {
                            Task {
                                await DataAnalyzer.shared.analyzeHealthData()
                            }
                        }
                    }
                }
            }
            
        }
        .tint(navbarTint)
    }
    
    private func fetchHealthData() {
        Task {
            do {
                //await hkManager.addSimulatorData()
                async let steps = hkManager.fetchStepCount()
                async let weightsForLineChart = hkManager.fetchWeights(daysBack: 28)
                async let weightsForDiffBarChart = hkManager.fetchWeights(daysBack: 29)
                
                hkData.stepData = try await steps
                hkData.weightData = try await weightsForLineChart
                hkData.weightDiffData = try await weightsForDiffBarChart
            } catch STError.authNotDetermined {
                isShowingPermissionPrimingSheet = true
            } catch STError.noData {
                fetchError = .noData
                isShowingAlert = true
            } catch {
                fetchError = .unableToCompleteRequest
                isShowingAlert = true
            }
        }
    }

}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
        .environment(HealthKitData())
}
