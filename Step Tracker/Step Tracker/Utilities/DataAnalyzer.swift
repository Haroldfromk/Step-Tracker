//
//  DataAnalyzer.swift
//  Step Tracker
//
//  Created by Dongik Song on 11/24/26.
//

import Foundation
import FoundationModels
import Playgrounds

@available(iOS 26, *)
@Observable
final class DataAnalyzer {
    static let shared = DataAnalyzer()
    let model: SystemLanguageModel = .default
    
    private init() { }
}

//@available(iOS 26, *)
//#Playground {
//    let session = LanguageModelSession()
//    let prompt = "Who would win in a fight between a bear and a lion"
//
//    do {
//        let response = try await session.respond(to: prompt)
//        print(response.content)
//    } catch {
//        print(error)
//    }
//}
//
