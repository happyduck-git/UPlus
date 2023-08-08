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
    enum MyPageViewMissionSectionType: String, CaseIterable {
        case today
        case routine = "루틴 미션"
        case weekly = "여정 미션"
        case button
        case calendar
    }
    
    enum MyPageViewEventSectionType: CaseIterable {
        case mission
    }
    
    let missionSections: [MyPageViewMissionSectionType] = MyPageViewMissionSectionType.allCases
    let eventSections: [MyPageViewEventSectionType] = MyPageViewEventSectionType.allCases
    
    //MARK: - DataSource
    /* Basic Data */
    let isJustRegistered: Bool
    let isVIP: Bool
    
    /* MyPageVC */
    @Published var todayRank2: Int = UPlusServiceInfoConstant.totalMembers
    @Published var weeklyMissions: [String: [Timestamp]] = [:]
    var dailyMissions: [String: [Timestamp]] = [:]
    @Published var isHistorySectionOpened: Bool = false
    @Published var savedMissionType: MissionType?
    @Published var routineParticipationCount: Int = 0
    @Published var routinePoint: Int64 = 0
    
    /* Event tap */
    @Published var eventMissions: [any Mission] = []
    
    /* Mission Select BottomVC */
    @Published var topButton: Bool = false
    @Published var midButton: Bool = false
    @Published var bottomButton: Bool = false
    @Published var buttonStatus: [Bool] = Array(repeating: false, count: 3)
    @Published var selectedMission: MissionType?
    
    //MARK: - Properties
    let user: UPlusUser
    let todayRank: Int
    @Published var missionViewModel: MissionMainViewViewModel?
    
    init(user: UPlusUser,
         isJustRegistered: Bool,
         isVip: Bool,
         todayRank: Int
    ) {
        self.user = user
        self.isJustRegistered = isJustRegistered
        self.isVIP = isVip
        self.todayRank = todayRank
        
        Task {
            async let _ = self.getSelectedRoutine()
            async let _ = self.createMissionMainViewViewModel()
//            async let _ = self.getTodayRank(of: String(describing: user.userIndex))
            async let _ = self.getMissionsTimeline()
//            async let _ = self.getEventMission()
        }
        
    }
}

//MARK: - Fetch Data from FireStore
extension MyPageViewViewModel {
    
    // TODO: Need to fix logic
    func getTodayRank(of userIndex: String) async {
        
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
    
    /// Get Start and End Time Map for All Missions
    func getMissionsTimeline() async {
        do {
            let results = try await firestoreManager.getAllMissionDate()
            let weeklyMissions = results.filter {
                $0.key.hasPrefix("weekly")
            }
            self.weeklyMissions = weeklyMissions
            
            let dailyMissions = results.filter {
                $0.key.hasPrefix("daily")
            }
            self.dailyMissions = dailyMissions
        }
        catch {
            print("Error fetching missions by date -- \(error)")
        }
    }
    
    
    /// Get User Selected Routine Mission If Any.
    func getSelectedRoutine() async {
        
        do {
            let user = try UPlusUser.getCurrentUser()
            self.savedMissionType = try await firestoreManager.getUserSelectedRoutineMission(userIndex: user.userIndex)
            
            if let savedType = self.savedMissionType {
                self.getRoutineParticipationCount(type: savedType)
            }
        }
        catch {
            print("Error retrieving selected routine mission -- \(error)")
        }
        
    }
    
    /// Get Number of Pariticipated Days of Routine Missions.
    func getRoutineParticipationCount(type: MissionType) {
        Task {
            do {
                let user = try UPlusUser.getCurrentUser()
                
                // 1. 선택한 루틴 미션DB 조회
                let missions = try await self.firestoreManager.getRoutineMission(type: type)
                let userMap = missions.compactMap { mission in
                    mission.missionUserStateMap
                }
                // 2. 참여 현황 조회
                let currentUser = userMap.filter { map in
                    map.contains { ele in
                        ele.key == String(describing: user.userIndex)
                    }
                }
                self.routineParticipationCount = currentUser.count
                
                // 3. 전체 포인트 계산
                let totalPoint = missions.reduce(0, {
                    $0 + $1.missionRewardPoint
                })
                
                self.routinePoint = totalPoint
            }
            catch {
                print("Error fetching participation count: \(error)")
            }
        }
    }
    
    func getEventMission() {
        Task {
            do {
                self.eventMissions = try await self.firestoreManager.getEvent()
                print("Mssioon; \(eventMissions.count)")
            }
            catch {
                print("Error fetching event missions -- \(error)")
            }
        }
    }
    
    func getNft(reference: DocumentReference) async throws -> UPlusNft {
        return try await self.firestoreManager.getNft(reference: reference)
    }
    
    func createMissionMainViewViewModel() async {
        do {
            let userInfo = try UPlusUser.getCurrentUser()
            let nft = await self.getMemberNft(userIndex: userInfo.userIndex,
                                        isVip: userInfo.userHasVipNft)
            
            self.missionViewModel = MissionMainViewViewModel(
                profileImage: nft,
                username: userInfo.userNickname,
                points: userInfo.userTotalPoint ?? 0,
                maxPoints: 15,
                level: 1,
                numberOfMissions: Int64(userInfo.userTypeMissionArrayMap?.values.count ?? 0),
                timeLeft: 12
            )
        }
        catch {
            print("Error creating mission main view model -- \(error)")
        }
        
    }
    
    private func getMemberNft(userIndex: Int64, isVip: Bool) async -> String {
        do {
            return try await self.firestoreManager.getMemberNft(userIndex: userIndex,
                                               isVip: isVip)
        }
        catch {
            print("Error fetching hold nft -- \(error)")
            return String()
        }
        
    }
}

//MARK: - Save Data to FireStore
extension MyPageViewViewModel {
    func saveSelectedMission(_ type: MissionType) async {
        do {
            let user = try UPlusUser.getCurrentUser()
            try await firestoreManager.saveSelectedRoutineMission(type: type,
                                                                  userIndex: user.userIndex)
            print("Saving mission type successed.")
        }
        catch {
            print("Error saving selected mission type -- \(error)")
        }
    }
}
