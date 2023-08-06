
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
    var numberOfWeek: Int = 1
    var title: String = "UPlus 알아가기"
    var missionDays: String = "미션 참여 기간: 08.07 - 08.14"
    var nftImage: UIImage? = nil
    
    /* Missions */
    @Published var missions: [WeeklyQuizMission] = [] {
        didSet {
            do {
                let user = try UPlusUser.getCurrentUser()
                for mission in self.missions {
                    let map = mission.missionUserStateMap ?? [:]
                    let hasParticipated = map.contains { ele in
                        ele.key == String(describing: user.userIndex)
                    }
                    self.participation[mission.missionId] = hasParticipated
                }
            }
            catch {
                print("Error getting user info from UserDefaults -- \(error)")
            }
        }
    }
    var participation: [Int64: Bool] = [:]
    
    private let dateFormatter: DateFormatter = {
       let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    init() {
        self.numberOfWeek = self.getNumberOfWeek()
        self.getWeeklyMissionInfo(week: self.numberOfWeek)
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
                self.missions = try await self.firestoreManager.getWeeklyMission(week: week)
            }
            catch {
                print("Error fetching weekly mission data -- \(error)")
            }
        }
    }
}
