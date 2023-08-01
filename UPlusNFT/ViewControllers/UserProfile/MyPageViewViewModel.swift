//
//  MyPageViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/26.
//

import Foundation
import FirebaseFirestore
import Combine

final class MyPageViewViewModel {
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    //MARK: - Sections
    enum MyPageViewSectionType: String, CaseIterable {
        case today
        case routine = "루틴 미션"
        case weekly = "여정 미션"
        case button
        case calendar
    }
    
    let sections: [MyPageViewSectionType] = MyPageViewSectionType.allCases
    
    //MARK: - DataSource
    @Published var todayRank2: Int = UPlusServiceInfoConstant.totalMembers
    @Published var weeklyMissions: [String: [Timestamp]] = [:]
    var dailyMissions: [String: [Timestamp]] = [:]
    @Published var isHistorySectionOpened: Bool = false
    
    //MARK: - Properties
    let user: UPlusUser
    let todayRank: Int
    let missionViewModel: MissionMainViewViewModel
    
    init(user: UPlusUser,
         todayRank: Int,
         missionViewModel: MissionMainViewViewModel
    ) {
        self.user = user
        self.todayRank = todayRank
        self.missionViewModel = missionViewModel
        
        self.getTodayRank(of: String(describing: user.userIndex))
        self.getMissionsTimeline()
    }
}

//MARK: - Fetch Data from FireStore
extension MyPageViewViewModel {
    func getTodayRank(of userIndex: String) {
        Task {
            
            do {
                let results = try await firestoreManager.getAllUserTodayPoint()
                let rank = results.firstIndex {
                    return String(describing: $0.userIndex) == userIndex
                } ?? (UPlusServiceInfoConstant.totalMembers - 1)
                self.todayRank2 = rank + 1
            }
            catch {
                print("Error getting today's points: \(error)")
            }
            
        }
    }
    
    func getMissionsTimeline() {
        Task {
            let results = try await firestoreManager.getMissionDate()
            let weeklyMissions = results.filter {
                $0.key.hasPrefix("weekly")
            }
            self.weeklyMissions = weeklyMissions
            
            let dailyMissions = results.filter {
                $0.key.hasPrefix("daily")
            }
            self.dailyMissions = dailyMissions
        }
    }
}
