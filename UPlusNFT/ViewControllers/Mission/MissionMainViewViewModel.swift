//
//  MissionMainViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/18.
//

import Foundation
import Combine

final class MissionMainViewViewModel {
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - Porperties
    enum SectionType: String, CaseIterable {
        case profile
        case todayMission
        case dailyAttendanceMission = "데일리 퀴즈"
        case expMission = "갓생 인증 미션"
    }
    
    var sections: [SectionType] = SectionType.allCases
    
    // STH holder인지 확인.
    var isHolder: Bool = false
    
    /* Mission Profile Section */
    let profileImage: String
    let username: String
    let points: Int64
    let maxPoints: Int64
    let level: Int64
    
    /* Today Mission Section */
    let numberOfMissions: Int64
    let timeLeft: Int64
    
    /* Daily Quiz Section */
    @Published var dailyAttendanceMissions: [DailyAttendanceMission] = []
    let quizTitle: String
    let quizDesc: String
    let quizPoint: Int64
    
    /* Long Term Mission Section */
    let longTermMissionCellVMList: [DailyMissionCollectionViewCellViewModel]
    
    /* Sudden Mission Section */
    @Published var suddenMissions: [SuddenMission] = []
    
    init(profileImage: String,
         username: String,
         points: Int64,
         maxPoints: Int64,
         level: Int64,
         numberOfMissions: Int64,
         timeLeft: Int64,
         quizTitle: String,
         quizDesc: String,
         quizPoint: Int64,
         dailyMissionCellVMList: [DailyMissionCollectionViewCellViewModel]
    ) {
        self.profileImage = profileImage
        self.username = username
        self.points = points
        self.maxPoints = maxPoints
        self.level = level
        self.numberOfMissions = numberOfMissions
        self.timeLeft = timeLeft
        self.quizTitle = quizTitle
        self.quizDesc = quizDesc
        self.quizPoint = quizPoint
        self.longTermMissionCellVMList = dailyMissionCellVMList
    }
    
}

// MARK: - Fetch Data from Firestore
extension MissionMainViewViewModel {
    
    func getDailyAttendanceMission() {
        Task {
            do {
                self.dailyAttendanceMissions = try await self.firestoreManager.getAllDailyAttendanceMission()
            }
            catch {
                print("Error fetching Daily Attendance Missions -- \(error)")
            }
        }
    }
    
    func getSuddenMission() {
        Task {
            do {
                self.suddenMissions = try await self.firestoreManager.getSuddenMission()
            }
            catch {
                print("Error fetching Sudden Missions -- \(error)")
            }
        }
    }
  
}
