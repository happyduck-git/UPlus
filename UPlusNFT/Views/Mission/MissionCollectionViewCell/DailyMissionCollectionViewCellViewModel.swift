//
//  DailyMissionCollectionViewCellViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/19.
//

import Foundation

final class DailyMissionCollectionViewCellViewModel {
    
    let missionTitle: String
    let missionImage: String
    let missionPoint: Int64
    let missionCount: Int64
    
    init(missionTitle: String, missionImage: String, missionPoint: Int64, missionCount: Int64) {
        self.missionTitle = missionTitle
        self.missionImage = missionImage
        self.missionPoint = missionPoint
        self.missionCount = missionCount
    }
    
}
