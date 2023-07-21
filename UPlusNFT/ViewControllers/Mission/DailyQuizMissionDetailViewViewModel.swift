//
//  DailyQuizMissionDetailViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/20.
//

import Foundation
import Combine

final class DailyQuizMissionDetailViewViewModel {
    
    let dataSource: DailyAttendanceMission
    
    @Published var circleButtonDidTap: Bool = false
    @Published var xButtonDidTap: Bool = false
    @Published var selectedAnswer: Int64 = 0
    @Published var answerDidCheck: Bool = false

    
    init(dataSource: DailyAttendanceMission) {
        self.dataSource = dataSource
    }
    
}
