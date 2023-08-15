//
//  MyMissionsCollectionViewCellViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/25.
//

import Foundation

final class MyMissionsCollectionViewCellViewModel {
    var point: Int64
    var missionTitle: String
    
    init(point: Int64, missionTitle: String) {
        self.point = point
        self.missionTitle = missionTitle
    }
}
