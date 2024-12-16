//
//  WeightDiffBarChartView.swift
//  Step Tracker
//
//  Created by Dongik Song on 12/16/24.
//

import SwiftUI
import Charts

struct WeightDiffBarChartView: View {
    
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    
    var chartData: [WeekdayChartData]
    
    var selectedData: WeekdayChartData? {
        guard let rawSelectedDate else { return nil }
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Label("Steps", systemImage: "figure")
                        .font(.title3.bold())
                        .foregroundStyle(.indigo)
                    
                    Text("Per Weekday (Last 28 Days)")
                        .font(.caption)
                }
                
                Spacer()
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)
            
            if chartData.isEmpty {
                ChartEmptyView(systemImageName: "chart.bar", title: "No Data", description: "There is no weight data from the Health App.")
            } else {
                Chart {
                    if let selectedData {
                        RuleMark(x: .value("Selected Data", selectedData.date, unit: .day))
                            .foregroundStyle(Color.secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(position: .top,
                                        spacing: 0,
                                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                annotationView
                            }
                    }
                    
                    ForEach(chartData) { weight in
                        BarMark(
                            x: .value("Date", weight.date, unit: .day),
                            y: .value("Diff", weight.value)
                        )
                        .foregroundStyle(weight.value > 0 ? Color.indigo.gradient : Color.mint.gradient)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisValueLabel(format: .dateTime.weekday(), centered: true)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(Color.secondary.opacity(0.3))
                        AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))                }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .sensoryFeedback(.impact(flexibility: .solid, intensity: 10), trigger: selectedDay)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
        }
    }
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedData?.date ?? .now, format: .dateTime.weekday(.wide))
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            
            Text(selectedData?.value ?? 0, format: .number.sign(strategy: .always()).precision(.fractionLength(2)))
                .fontWeight(.heavy)
                .foregroundStyle((selectedData?.value ?? 0) > 0 ? Color.indigo : Color.mint)
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
    WeightDiffBarChartView(chartData: MockData.weightDiffs)
}
