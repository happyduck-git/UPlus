//
//  AnswerQuizSingularViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import Foundation
import Combine

final class AnswerQuizSingularViewViewModel {
    let mission: ShortAnswerQuizMission
    let numberOfWeek: Int
    
    init(mission: ShortAnswerQuizMission, numberOfWeek: Int) {
        self.mission = mission
        self.numberOfWeek = numberOfWeek
    }
}
