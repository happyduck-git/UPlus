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
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()

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
    typealias Membership = (isJustRegisterd: Bool, isVIP: Bool)
    let user: UPlusUser
    var memberShip: Membership
    
    @Published var userProfileViewModel: UserProfileViewViewModel?
    @Published var newPoint: Int64 = 0
    @Published var rank: Int = UPlusServiceInfoConstant.totalMembers
    
    class MyPageMission {
        
        weak var parent: MyPageViewViewModel?
        
        @Published var weeklyMissions: [String: [Timestamp]] = [:]
        var dailyMissions: [String: [Timestamp]] = [:]
        @Published var isHistorySectionOpened: Bool = false
        
        @Published var savedMissionType: MissionType?
        
        @Published var routineParticipationCount: Int = 0
        @Published var routinePoint: Int64 = 0
        
        /* Calendar Cell */
        // Total missions
        var isPointHistoryFetched: Bool = false
        @Published var participatedHistory: [PointHistory] = []
        @Published var participatedMissions: [any Mission] = []
        @Published var missionDates: [String] = []
        
        // Selected date's missions
        var isDateSelected: Bool = false
        var dateSelected = PassthroughSubject<Date,Never>()
        @Published var selectedDatePointHistory: PointHistory? {
            didSet {
                Task {
                    do {
                        let docRefs = selectedDatePointHistory?.userPointMissions ?? []
                        
                        let results = try await parent?.convertToListOfMission(docRefs: docRefs)
                        self.selectedDateMissions = results ?? []
                    }
                    catch {
                        print("Error converting doc ref to Mission -- \(error)")
                    }
                }
            }
        }
        
        @Published var selectedDateMissions: [any Mission] = []
    }
    
    class MyPageEvent {
        @Published var eventMissions: [any Mission] = []
    }
    
    class MissionSelectBottomView {
        /* Mission Select BottomVC */
        @Published var topButton: Bool = false
        @Published var midButton: Bool = false
        @Published var bottomButton: Bool = false
        @Published var buttonStatus: [Bool] = Array(repeating: false, count: 3)
        @Published var selectedMission: MissionType?
    }
    
    var mission = MyPageMission()
    var event = MyPageEvent()
    var bottomView = MissionSelectBottomView()
    
    //MARK: - Init
    init(user: UPlusUser,
         memberShip: Membership
    ) {
        
        self.user = user
        self.memberShip = memberShip
        self.mission.parent = self
        Task {
            await self.getSelectedRoutine()
            
            await self.createMissionMainViewViewModel()
            
            await self.getMissionsTimeline()
            
            await self.getEventMission()
            
            await self.getTodayRank()
        }
        
    }
}

//MARK: - Fetch Data from FireStore
extension MyPageViewViewModel {
    
    /// Get Start and End Time Map for All Missions
    func getMissionsTimeline() async {
        do {
            let results = try await firestoreManager.getAllMissionDate()
            let weeklyMissions = results.filter {
                $0.key.hasPrefix("weekly")
            }
            self.mission.weeklyMissions = weeklyMissions
            
            let dailyMissions = results.filter {
                $0.key.hasPrefix("daily")
            }
            self.mission.dailyMissions = dailyMissions
        }
        catch {
            print("Error fetching missions by date -- \(error)")
        }
    }
    
    
    /// Get User Selected Routine Mission If Any.
    func getSelectedRoutine() async {
        
        do {
            self.mission.savedMissionType = try await firestoreManager.getUserSelectedRoutineMission(userIndex: self.user.userIndex)
            
            if let savedType = self.mission.savedMissionType {
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
                self.mission.routineParticipationCount = currentUser.count
                
                // 3. 전체 포인트 계산
                let totalPoint = missions.reduce(0, {
                    $0 + $1.missionRewardPoint
                })
                
                self.mission.routinePoint = totalPoint
            }
            catch {
                print("Error fetching participation count: \(error)")
            }
        }
    }
    
    func getEventMission() async {
        do {
            self.event.eventMissions = try await self.firestoreManager.getEvent()
            print("Mssioon; \(self.event.eventMissions.count)")
        }
        catch {
            print("Error fetching event missions -- \(error)")
        }
    }
    
    func createMissionMainViewViewModel() async {
        
        let token = await self.getTopLevelNftToken() ?? "no-url"
        let nftUrl = await self.firestoreManager.getNftUrl(tokenId: token)
        
        self.userProfileViewModel = UserProfileViewViewModel(
            profileImage: nftUrl,
            username: self.user.userNickname,
            points: self.user.userTotalPoint ?? 0,
            maxPoints: 15,
            level: 1,
            timeLeft: 12
        )
        
    }
    
    func fetchPointHistory() async {
        do {
            // 1. Fetch entire point hitory of the user.
            let pointHistory = try await self.firestoreManager.getAllParticipatedMissionHistory(user: self.user)
            self.mission.participatedHistory = pointHistory
            
            // 2. Parse mission doc references of each PointHistory.
            var missions: [any Mission] = []
            var dates: [String] = []
            
            for history in pointHistory {
                let docRefs = history.userPointMissions ?? []
                let date = history.userPointTime
                
                let results = try await self.convertToListOfMission(docRefs: docRefs)
              
                missions.append(contentsOf: results)
                if results.count > 0 {
                    dates.append(date)
                }
            }
            self.mission.missionDates = dates
            self.mission.participatedMissions = missions
            
        }
        catch {
            print("Error fetching point history -- \(error)")
        }
    }
    
    func convertToListOfMission(docRefs: [DocumentReference]) async throws -> [any Mission] {
        
        var missions: [any Mission] = []
       
        for ref in docRefs {
            guard let mission = try await self.firestoreManager.convertToMission(doc: ref) else {
                continue
            }
            missions.append(mission)
        }
        return missions
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

extension MyPageViewViewModel {
    func getTodayRank() async {
 
        do {
            let history = try await FirestoreActor.shared.getTodayPointHistory()
            let rank = history.firstIndex {
                $0.userIndex == String(describing: self.user.userIndex)
            }
            guard let rnk = rank else { return }
            self.rank = rnk + 1
        }
        catch {
            print("Error fething today point -- \(error)")
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

