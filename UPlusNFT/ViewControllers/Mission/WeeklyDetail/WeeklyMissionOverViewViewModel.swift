
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
    
    private let dateFormatter: DateFormatter = {
       let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    // MARK: - Init
    init(week: Int) {
        self.week = week
//        self.numberOfWeek = self.getNumberOfWeek()
        self.getWeeklyMissionInfo(week: week)
    }
    
}

extension WeeklyMissionOverViewViewModel {
    
    /// Calculate current number of week from the service start date.
    /// - Returns: Number of week.
    private func getNumberOfWeek() -> Int {
        let currentDate = Date()
        
        guard let startDate = self.dateFormatter.date(from: UPlusServiceInfoConstant.startDay) else {
            return 0
        }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: currentDate)
        
        guard let day = components.day else {
            return 0
        }
        
        return (day / 7) + 1
    }
    
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
