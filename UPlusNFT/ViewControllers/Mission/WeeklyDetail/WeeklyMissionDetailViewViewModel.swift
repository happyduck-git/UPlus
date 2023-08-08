//
//  DailyQuizMissionDetailViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/20.
//

import Foundation
import Combine

final class WeeklyMissionDetailViewViewModel {
    
//    let dataSource: WeeklyQuizMission
    let dataSource: any Mission
    
    let numberOfWeek: Int
    
    /* Choice Quiz */
    @Published var circleButtonDidTap: Bool = false
    @Published var xButtonDidTap: Bool = false
    @Published var selectedAnswer: Int64 = 0
    @Published var answerDidCheck: Bool = false

    /* Answer Quiz */
    @Published var textExists: Bool = false
    
    
    init(dataSource: any Mission,
         numberOfWeek: Int) {
        self.dataSource = dataSource
        self.numberOfWeek = numberOfWeek
    }
    
}
