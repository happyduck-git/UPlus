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
        case history
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
    @Published var newPoint: Int64 = 0
    
    /* MyPageVC */
    @Published var todayRank2: Int = UPlusServiceInfoConstant.totalMembers
    @Published var weeklyMissions: [String: [Timestamp]] = [:]
    var dailyMissions: [String: [Timestamp]] = [:]
    @Published var isHistorySectionOpened: Bool = false
    @Published var savedMissionType: MissionType?
    @Published var routineParticipationCount: Int = 0
    @Published var routinePoint: Int64 = 0
    
    var isPointHistoryFetched: Bool = false
    
    // Total missions
    @Published var pointHistory: [String: PointHistory] = [:] {
        didSet {
            for history in pointHistory.values {
                let docRefs = history.userPointMissions ?? []

                Task {
                    do {
                        var missions: [String] = []
                        for docRef in docRefs {
                            let data = try await docRef.getDocument().data()
                            let title = data?[FirestoreConstants.missionContentTitle] as? String ?? "no-title"
                            missions.append(title)
                        }
                        self.participatedMissions = missions
                    }
                    catch {
                        print("Error getting data -- \(error)")
                    }
                }
            }
            
        }
    }
    @Published var participatedMissions: [String] = []
    
    // Selected date's missions
    @Published var selectedDatePointHistory: PointHistory? {
        didSet {
            Task {
                let docs = selectedDatePointHistory?.userPointMissions ?? []
                var info: [(type: MissionTopicType, title: String, point: Int64)?] = []
                for doc in docs {
                    info.append(try await self.firestoreManager.convertToMission(doc: doc))
                }
                self.selectedDateMissionInfo = info
            }
        }
    }
    
    @Published var selectedDateMissionInfo: [(type: MissionTopicType, title: String, point: Int64)?] = []
    
    /* Calendar Cell */
    var dateSelected = PassthroughSubject<Date,Never>()
    
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
            await self.getSelectedRoutine()
            print("getSelectedRoutine finished")
            await self.createMissionMainViewViewModel()
            print("createMissionMainViewViewModel finished")
//            async let _ = self.getTodayRank(of: String(describing: user.userIndex))
            await self.getMissionsTimeline()
            print("getMissionsTimeline finished")
            await self.getEventMission()
            print("getEventMission finished")
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
            self.savedMissionType = try await firestoreManager.getUserSelectedRoutineMission(userIndex: self.user.userIndex)
            
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
                // 1. 선택한 루틴 미션DB 조회
                let missions = try await self.firestoreManager.getRoutineMission(type: type)
                let userMap = missions.compactMap { mission in
                    mission.missionUserStateMap
                }
                // 2. 참여 현황 조회
                let currentUser = userMap.filter { map in
                    map.contains { ele in
                        ele.key == String(describing: self.user.userIndex)
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
    
    func getEventMission() async {
        do {
            self.eventMissions = try await self.firestoreManager.getEvent()
            print("Mssioon; \(eventMissions.count)")
        }
        catch {
            print("Error fetching event missions -- \(error)")
        }
    }
    
    func createMissionMainViewViewModel() async {

            let token = await self.getTopLevelNftToken() ?? "no-url"
            let nftUrl = await self.firestoreManager.getNftUrl(tokenId: token)
            
            self.missionViewModel = MissionMainViewViewModel(
                profileImage: nftUrl,
                username: self.user.userNickname,
                points: self.user.userTotalPoint ?? 0,
                maxPoints: 15,
                level: 1,
                numberOfMissions: Int64(self.user.userTypeMissionArrayMap?.values.count ?? 0),
                timeLeft: 12
            )
        
    }
    
    func fetchPointHistory() async {
        do {
            self.pointHistory = try await self.firestoreManager.getAllParticipatedMissionHistory(user: self.user)
        }
        catch {
            print("Error fetching point history -- \(error)")
        }
    }
}

extension MyPageViewViewModel {
    
    private func getTopLevelNftToken() async -> String? {
        let tokens = await self.updateUserOwnedNft()
        guard let topNft = tokens.last else { return nil }
        
        return topNft
    }
    
    private func updateUserOwnedNft() async -> [String] {

            do {
                // 1. Fetch NFTs from Luniverse
                    // token Id 확인
                let token = try await LuniverseServiceManager.shared.requestAccessToken()
                let nfts = try await LuniverseServiceManager.shared.requestNftList(authKey: token,
                                                                                   walletAddress: self.user.userWalletAddress ?? "n/a")
                
                let nftTokens: [String] = nfts.data.items.map { $0.tokenId }.reversed()
                
                // 2. Fetch NFTs from Firestore
                let savedNfts = user.userNfts ?? []
                
                let savedTokens = savedNfts.compactMap { self.extractNumberString(from: $0.path) }
 
                // API fetched NFTs & Firestore fetched NFTs 가 동일한지 확인
                if !self.haveSameElements(nftTokens, savedTokens) {
                    // 동일하지 않다면, user_nfts의 reference 업데이트
                    self.updateNftList(nfts: nftTokens, userIndex: user.userIndex)
                }
                return nftTokens
            }
            catch {
                print("Error requesting Luniverse access token -- \(error)")
                return []
            }
   
    }
    
    // user_nfts의 reference 업데이트
    private func updateNftList(nfts: [String], userIndex: Int64) {
        Task {
            do {
                try await firestoreManager.updateOwnedNfts(tokens: nfts, userIndex: userIndex)
            }
            catch {
                print("Error updating nft list -- \(error.localizedDescription)")
            }
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

//MARK: - Save Data to FireStore
extension MyPageViewViewModel {
    func saveUserToUserDefaults() {
        Task {
            do {
                let user = try await UPlusUser.saveCurrentUser(email: user.userEmail)
                newPoint = user.userTotalPoint ?? 0
            }
            catch {
                print("Error saving current user -- \(error)")
            }
        }
    }
}

//MARK: - Utilities
extension MyPageViewViewModel {
    private func extractNumberString(from string: String) -> String? {
        
        let components = string.split(separator: "/")
        return components.last.map { String($0) }
    }
    
    private func haveSameElements(_ arr1: [String], _ arr2: [String]) -> Bool {
        return Set(arr1) == Set(arr2)
    }
}
