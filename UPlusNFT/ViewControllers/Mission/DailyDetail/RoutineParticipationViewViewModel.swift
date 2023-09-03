//
//  RoutineParticipationViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/16.
//

import Foundation
import Combine

final class RoutineParticipationViewViewModel {
    private let nftServiceManager = NFTServiceManager.shared
    
    let mission: any Mission
    var count: Int {
        didSet {
            var point = mission.missionRewardPoint
            if count == 5 || count == 10 || count == 21 {
                point += 100
            }
            self.pointToGive = point
        }
    }
    var pointToGive: Int64 = 0
    
    //MARK: - Init
    init(mission: any Mission, count: Int) {
        self.mission = mission
        self.count = count
    }
}

extension RoutineParticipationViewViewModel {
    func requestRoutineNft() async {
        do {
            let user = try UPlusUser.getCurrentUser()
            let _ = try await nftServiceManager.requestSingleNft(userIndex: user.userIndex,
                                               nftType: .goodWorker)
        }
        catch {
            UPlusLogger.logger.error("Error requesting Routine NFT -- \(String(describing: error))")
        }
    }
}
