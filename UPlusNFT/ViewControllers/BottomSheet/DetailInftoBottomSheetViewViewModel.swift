//
//  DetailInftoBottomSheetViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/30.
//

import UIKit.UIImage

enum MissionHeaderType {
    case contest
    case level
    case master
    case world
    
    var title: String {
        switch self {
        case .contest:
            return InfoBottomConstants.contest
        case .level:
            return InfoBottomConstants.level
        case .master:
            return InfoBottomConstants.master
        case .world:
            return InfoBottomConstants.world
        }
    }
    
    var image: UIImage? {
        switch self {
        case .contest:
            return UIImage(named: ImageAssets.detailsContest)
        case .level:
            return UIImage(named: ImageAssets.detailsLevel)
        case .master:
            return UIImage(named: ImageAssets.detailsMaster)
        case .world:
            return UIImage(named: ImageAssets.detailsWorld)
        }
    }
    
}

final class DetailInftoBottomSheetViewViewModel {
    
    let type: MissionHeaderType
    
    init(type: MissionHeaderType) {
        self.type = type
    }
    
}
