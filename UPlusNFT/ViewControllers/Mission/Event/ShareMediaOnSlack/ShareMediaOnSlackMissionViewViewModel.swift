//
//  ShareMediaOnSlackMissionViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import Foundation
import Combine

final class ShareMediaOnSlackMissionViewViewModel {
    
    let mission: MediaShareMission
    
    @Published var imageUrls: [URL] = []
    
    init(mission: MediaShareMission) {
        self.mission = mission
        
    }
}

extension ShareMediaOnSlackMissionViewViewModel {
   
}

