//
//  StepPieChartView.swift
//  Step Tracker
//
//  Created by Dongik Song on 12/15/24.
//

import SwiftUI
import Charts

struct StepPieChartView: View {
    
    @State private var rawSelectedChartValue: Double? = 0
    @State private var selectedDay: Date?
    
    var chartData: [DateValueChartData] = []
    
    var selectedWeekday: DateValueChartData? {
        guard let rawSelectedChartValue else { return nil }
        var total = 0.0
        
        let selectedData = chartData.first {
            total += $0.value
            return rawSelectedChartValue <= total
        }
        return selectedData
    }
    
    var body: some View {
        ChartContainer(title: "Averages",
                       symbol: "figure.walk",
                       subtitle: "Last 28 Days",
                       context: .steps,
                       isNav: false
        ) {
            if chartData.isEmpty {
                ChartEmptyView(systemImageName: "calendar", title: "No Data", description: "There is no step count data from the Health App.")
            } else {
                Chart {
                    ForEach(chartData) { weekday in
                        SectorMark(angle: .value("Average Steps", weekday.value),
                                   innerRadius: .ratio(0.618),
                                   outerRadius: selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 140 : 110,
                                   angularInset: 1)
                        .foregroundStyle(.pink.gradient)
                        .cornerRadius(6)
                        .opacity(selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 1.0 : 0.3 )
                    }
                }
                .chartAngleSelection(value: $rawSelectedChartValue.animation(.easeOut))
                .frame(height: 240)
                .chartBackground { proxy in
                    GeometryReader { geo in
                        if let plotFrame = proxy.plotFrame {
                            let frame = geo[plotFrame]
                            if let selectedWeekday {
                                VStack {
                                    Text(selectedWeekday.date.weekdayTitle)
                                        .font(.title3.bold())
                                        .animation(nil)
                                    
                                    Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                        .contentTransition(.numericText())
                                }
                                .position(x: frame.midX, y: frame.midY)
                            }
                        }
                    }
                }
            }
        }
        .sensoryFeedback(.impact(flexibility: .solid, intensity: 10), trigger: selectedDay)
        .onChange(of: selectedWeekday) { oldValue, newValue in
            guard let oldValue, let newValue else { return }
            if oldValue.date.weekdayInt != newValue.date.weekdayInt {
                selectedDay = newValue.date
            }
        }
        
    }
    
}

#Preview {
    StepPieChartView(chartData: ChartMath.averageWeekdayCount(for: MockData.steps))
}
