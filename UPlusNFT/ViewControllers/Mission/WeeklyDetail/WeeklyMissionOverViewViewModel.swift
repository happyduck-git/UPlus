
//
//  WeeklyMissionOverViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/03.
//

import Foundation
import Combine
import UIKit.UIImage

final class WeeklyMissionOverViewViewModel {
    
    private let firestoreManager = FirestoreManager.shared

    /* Header */
    var week: Int = 1
    var title: String = "UPlus 알아가기"
    var missionDays: String = "미션 참여 기간: 08.07 - 08.14"
    var nftImage: UIImage? = nil
    
    /* Missions */
    var missionParticipation: [String: Bool] = [:]
    
    @Published var weeklyMissions: [any Mission] = [] {
        didSet {
            do {
                let user = try UPlusUser.getCurrentUser()
                for mission in self.weeklyMissions {
                    let map = mission.missionUserStateMap ?? [:]
                    let hasParticipated = map.contains { ele in
                        ele.key == String(describing: user.userIndex)
                    }
                    
                    self.missionParticipation[mission.missionId] = hasParticipated
                }
            }
            catch {
                print("Error getting user info from UserDefaults -- \(error)")
            }
        }
    }

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
