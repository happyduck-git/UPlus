//
//  ShareMediaOnSlackMissionViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import Foundation
import Combine

final class ShareMediaOnSlackMissionViewViewModel: MissionBaseModel {
    
    private let level: Int
    
    @Published var textFieldText: String = ""
    
    
    // MARK: - Init
    init(level: Int, type: MissionBaseModel.`Type`, mission: Mission, numberOfWeek: Int = 0) {
        self.level = level
        super.init(type: type, mission: mission)
        
    }
  
}

