//
//  ChoiceQuizzOXViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/20.
//

import Foundation
import Combine

final class ChoiceQuizzOXViewViewModel {
    
    let mission: any Mission
    
    let numberOfWeek: Int
    
    /* Choice Quiz */
    @Published var circleButtonDidTap: Bool = false
    @Published var xButtonDidTap: Bool = false
    @Published var selectedAnswer: Int64 = 0
    @Published var answerDidCheck: Bool = false

    /* Answer Quiz */
    @Published var textExists: Bool = false
    
    /* WeeklyMission Completion */
    @Published var weeklyMissionCompletion: Bool = false
    
    init(mission: any Mission,
         numberOfWeek: Int) {
        self.mission = mission
        self.numberOfWeek = numberOfWeek
    }
    
}
