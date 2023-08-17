//
//  GovernanceElectionMissionViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import Foundation
import Combine

final class GovernanceElectionMissionViewViewModel: EventBaseModel {
    
    enum ScreenType {
        case vote
        case result
    }
    
    @Published var screenType: ScreenType = .vote
    
    @Published var buttonStatus: [Bool] = []
    var selectedButton: Int?
    
    @Published var answerRatioMap: [String: Float] = [:]
    
}

extension GovernanceElectionMissionViewViewModel {
    
    private func saveEventParticipationLocally() {
        let selectedAnswer = self.selectedButton ?? 0
        let value = self.answerRatioMap[String(describing: selectedAnswer)] ?? 0.0
        self.answerRatioMap[String(describing: selectedAnswer)] = value + 1.0
    }
    
    func calculateAnswerRatio() {
        guard let mission = self.mission as? GovernanceMission else { return }
        let userMap = mission.governanceElectionUserMap ?? [:]
        
        var answerMap: [String: Float] = [:]
        
        var totalAnswers: Float = 0.0
        for key in userMap.keys {
            guard let value = userMap[key] else { continue }
            
            totalAnswers += Float(value.count)
            answerMap[key] = Float(value.count)
            
        }
        
        let selectedAnswer = String(describing: self.selectedButton ?? 0)
        let value = answerMap[String(describing: selectedAnswer)] ?? 0.0
        totalAnswers += 1
        
        answerMap[selectedAnswer] = value + 1.0
        
        self.answerRatioMap = answerMap.mapValues {
            $0 / totalAnswers
        }

    }
    
}

