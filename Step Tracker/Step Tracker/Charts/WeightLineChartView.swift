//
//  WeightLineChartView.swift
//  Step Tracker
//
//  Created by Dongik Song on 12/15/24.
//

import SwiftUI
import Charts

struct WeightLineChartView: View {
    
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    
    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    var body: some View {
        ChartContainer(title: "Weight",
                       symbol: "figure",
                       subtitle: "Avg: 180 lbs",
                       context: .weight,
                       isNav: true
        ) {
            if chartData.isEmpty {
                ChartEmptyView(systemImageName: "chart.xyaxis.line", title: "No Data", description: "There is no weight data from the Health App.")
            } else {
                Chart {
                    if let selectedHealthMetric {
                        RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit: .day))
                            .foregroundStyle(Color.secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(position: .top,
                                        spacing: 0,
                                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                annotationView
                            }
                    }
                    RuleMark(y: .value("Goal", 155))
                        .foregroundStyle(.mint)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                    
                    ForEach(chartData) { weights in
                        AreaMark(
                            x: .value("Day", weights.date, unit: .day),
                            yStart: .value("Value", weights.value),
                            yEnd: .value("Min Value", minValue)
                        )
                        .foregroundStyle(Gradient(colors: [.blue.opacity(0.5), .clear]))
                        .interpolationMethod(.catmullRom)
                                            
                        LineMark(x: .value("Day", weights.date, unit: .day),
                                 y: .value("Value", weights.value)
                        )
                        .foregroundStyle(.indigo)
                        .interpolationMethod(.catmullRom)
                        .symbol(.circle)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $rawSelectedDate)
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(Color.secondary.opacity(0.3))
                        AxisValueLabel()
                    }
                }
            }
        }
        .sensoryFeedback(.impact(flexibility: .solid, intensity: 10), trigger: selectedDay)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
        }
    }
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedHealthMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(1)))
                .fontWeight(.heavy)
                .foregroundStyle(.indigo)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        }
    }
    
}

#Preview {
    WeightLineChartView(selectedStat: .weight, chartData: MockData.weights)
}
