//
//  CoachView.swift
//  Step Tracker
//
//  Created by Dongik Song on 11/24/26.
//

import SwiftUI

@available(iOS 26.0, *)
struct CoachView: View {

    @Environment(\.dismiss) var dismiss
    let analyzer = DataAnalyzer.shared

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                Image(.craig)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(.circle)

                Text("Coach Craig")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button("Ok", systemImage: "checkmark") {
                    dismiss()
                }
                .padding(12)
                .labelStyle(.iconOnly)
                .clipShape(.circle)
                .glassEffect(.regular.tint(.pink).interactive())
            }

            ScrollView {
                Text(analyzer.coachMessage ?? "")
                    .contentTransition(.interpolate)
                    .animation(.easeInOut(duration: 0.8), value: analyzer.coachMessage)
            }
            .overlay {
                if analyzer.isThinking {
                    VStack(spacing: 16) {
                        Image(systemName: "apple.intelligence")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .symbolEffect(.pulse, options: .repeat(.continuous))

                        Text("Thinking...")
                            .font(.callout)
                    }
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 200)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

@available(iOS 26.0, *)
#Preview {
    CoachView()
}
