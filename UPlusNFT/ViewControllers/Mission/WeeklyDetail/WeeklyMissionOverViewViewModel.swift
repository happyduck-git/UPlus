
//
//  WeeklyMissionOverViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/03.
//

import Foundation
import Combine
import UIKit.UIImage
import OSLog

final class WeeklyMissionOverViewViewModel {
    
    private let logger = Logger()
    
    private let firestoreManager = FirestoreManager.shared
    private let nftServiceManager = NFTServiceManager.shared
    
    /* Header */
    var week: Int = 1
    var title: String = "UPlus 알아가기"
    var missionDays: String = "미션 참여 기간: 08.07 - 08.14"
    var nftImage: UIImage? = nil
    
    /* Missions */
    var missionParticipation: [String: Bool] = [:] {
        didSet {
            if missionParticipation.allSatisfy({ $0.value == true }) {
                self.weeklyMissionCompletion.send(true)
            } else {
                self.weeklyMissionCompletion.send(false)
            }
        }
    }
    
    @Published var weeklyMissions: [any Mission] = [] {
        didSet {
            do {
                let user = try UPlusUser.getCurrentUser()
                var status: [String: Bool] = [:]
                
                for mission in self.weeklyMissions {
                    let map = mission.missionUserStateMap ?? [:]
                    let hasParticipated = map.contains { ele in
                        ele.key == String(describing: user.userIndex)
                    }
                    
                    status[mission.missionId] = hasParticipated
                }
                self.missionParticipation = status
                
            }
            catch {
                print("Error getting user info from UserDefaults -- \(error)")
            }
        }
    }
    @Published var weeklyMissionCompletion = PassthroughSubject<Bool, Never>()
    
    @Published var nftIssueStatus = PassthroughSubject<Bool, NFTServiceError>()
    
    // MARK: - Init
    init(week: Int) {
        self.week = week
        self.getWeeklyMissionInfo(week: week)
    }
    
}

extension WeeklyMissionOverViewViewModel {
    
    func getWeeklyMissionInfo(week: Int) {
        Task {
            do {
                self.weeklyMissions = try await self.firestoreManager.getWeeklyMission(week: week)
            }
            catch {
                print("Error fetching weekly mission data -- \(error)")
            }
        }
    }

}

// MARK: - NFT Service
extension WeeklyMissionOverViewViewModel {
    
    func requestJourneyNft() {
        Task {
            do {
                let user = try UPlusUser.getCurrentUser()
                let result = try await nftServiceManager.requestSingleNft(
                    userIndex: user.userIndex,
                    nftType: .journey,
                    level: week
                )
                
                print("Result: \(result)")
                
                guard let status = NFTServiceStatus(rawValue: result.data.status) else { return }
                switch status {
                case .pending:
                    self.nftIssueStatus.send(true)
                case .fail:
                    self.nftIssueStatus.send(completion: .failure(.issueFailed))
                }
            }
            catch {
                print("Error requesting nft to NFTServiceInfra -- \(error)")
            }
        }
    }
}
