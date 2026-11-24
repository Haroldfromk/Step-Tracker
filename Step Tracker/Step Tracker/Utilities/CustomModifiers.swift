//
//  CustomModifiers.swift
//  Step Tracker
//
//  Created by Dongik Song on 11/18/26.
//

import SwiftUI

struct ProminentButton: ViewModifier {

    var color: Color

    func body(content: Content) -> some View {
        if #available(iOS 26, *){
            content
                .buttonStyle(.glassProminent)
                .tint(color)
        } else {
            content
                .buttonStyle(.borderedProminent)
                .tint(color)
        }
    }
}

struct BackportSheet: ViewModifier {
    @Binding var isPresented: Bool
    let namespace: Namespace.ID

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .sheet(isPresented: $isPresented) {
                    DataAnalyzer.shared.coachMessage = ""
                } content: {
                    CoachView()
                        .presentationDetents([.fraction(0.8)])
                        .navigationTransition(.zoom(sourceID: "coachview", in: namespace))
                }
        } else {
            content
        }
    }
}

extension View {
    func prominentButton(color: Color) -> some View {
        modifier(ProminentButton(color: color))
    }

    func backportSheet(isPresented: Binding<Bool>, namespace: Namespace.ID) -> some View {
        modifier(BackportSheet(isPresented: isPresented, namespace: namespace))
    }
}
