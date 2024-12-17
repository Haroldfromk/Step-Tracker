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
    
    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var body: some View {
        let config = ChartContainerConfiguration(title: "Weight",
                                                 symbol: "figure",
                                                 subtitle: "Per Weekday (Last 28 Days)",
                                                 context: .weight,
                                                 isNav: false)
        
        ChartContainer(config: config) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .weight)
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
                    AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName))) }
            }
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(systemImageName: "chart.bar", title: "No Data", description: "There is no weight data from the Health App.")
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
    
    //    var annotationView: some View {
    //        VStack(alignment: .leading) {
    //            Text(selectedData?.date ?? .now, format: .dateTime.weekday(.wide))
    //                .font(.footnote.bold())
    //                .foregroundStyle(.secondary)
    //
    //            Text(selectedData?.value ?? 0, format: .number.sign(strategy: .always()).precision(.fractionLength(2)))
    //                .fontWeight(.heavy)
    //                .foregroundStyle((selectedData?.value ?? 0) > 0 ? Color.indigo : Color.mint)
    //        }
    //        .padding(12)
    //        .background {
    //            RoundedRectangle(cornerRadius: 4)
    //                .fill(Color(.secondarySystemBackground))
    //                .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
    //        }
    //    }
    
    
}

#Preview {
    WeightDiffBarChartView(chartData: MockData.weightDiffs)
}
