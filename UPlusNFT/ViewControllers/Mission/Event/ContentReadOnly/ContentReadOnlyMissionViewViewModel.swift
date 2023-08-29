//
//  ContentReadOnlyMissionViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import Foundation
import Combine

final class ContentReadOnlyMissionViewViewModel: MissionBaseModel {
    
    //MARK: - Dependency
    private let storageManager = FirebaseStorageManager.shared
    
    override init(type: Type, mission: Mission, numberOfWeek: Int) {
        super.init(type: type, mission: mission, numberOfWeek: numberOfWeek)

    }

}
