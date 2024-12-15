//
//  WeightLineChartView.swift
//  Step Tracker
//
//  Created by Dongik Song on 12/15/24.
//

import SwiftUI
import Charts

struct WeightLineChartView: View {
    
    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]
    
    var body: some View {
        VStack {
            NavigationLink(value: selectedStat) {
                HStack {
                    VStack(alignment: .leading) {
                        Label("Steps", systemImage: "figure")
                            .font(.title3.bold())
                            .foregroundStyle(.indigo)
                        
                        Text("Avg: 180 lbs")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)
            
            Chart {
                ForEach(chartData) { weights in
                    AreaMark(x: .value("Day", weights.date, unit: .day),
                             y: .value("Value", weights.value)
                    )
                    .foregroundStyle(Gradient(colors: [.blue.opacity(0.5), .clear]))
                    
                    
                    LineMark(x: .value("Day", weights.date, unit: .day),
                             y: .value("Value", weights.value)
                    )
                }
            }
            .frame(height: 150)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    WeightLineChartView(selectedStat: .weight, chartData: MockData.weights)
}
