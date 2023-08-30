//
//  MyPageViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/26.
//

import Foundation
import FirebaseFirestore
import Combine
import OSLog

final class MyPageViewViewModel {

    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - Logger
    private let logger = Logger()
    
    //MARK: - Sections
    enum MyPageViewMissionSectionType: String, CaseIterable {
        case today
        case todayDetail = "마스터의 성공 습관 만들기"
        case weekly
        case weeklyDetail = "월드클래스 기업 만들기"
        case button
        case calendar
        case history
    }
    
    enum MyPageViewEventSectionType: String, CaseIterable {
        case availableEvent
        case regularEvent = "콘테스트"
        case empty
        case levelEvent = "스페셜 이벤트"
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
    @Published var updatedNfts: [String] = [] {
        didSet {
            updatedNftsCopy = updatedNfts
        }
    }
    
    var updatedNftsCopy: [String] = []
    
    var isRefreshing: Bool = false
    
    class MyPageMission {
        
        weak var parent: MyPageViewViewModel?
        
        @Published var missionBaseInfo: MissionBaseInfo? {
            didSet {
                // Timeline
                let timelineMap = missionBaseInfo?.missionsBeginEndTimeMap ?? [:]
                self.parent?.sortMissionsTimeline(timeline: timelineMap)
                
                // Title
                self.missionTitles.append(missionBaseInfo?.extraWeeklyQuiz1.episodeTitle ?? "no-title")
                self.missionTitles.append(missionBaseInfo?.extraWeeklyQuiz2.episodeTitle ?? "no-title")
                self.missionTitles.append(missionBaseInfo?.extraWeeklyQuiz3.episodeTitle ?? "no-title")
            }
        }
        
        @Published var weeklyMissions: [String: [Timestamp]] = [:]
        var dailyMissions: [String: [Timestamp]] = [:]
        var missionTitles: [String] = []
        
        @Published var numberOfFinishedMissions: [Int] = []
        
        @Published var isHistorySectionOpened: Bool = false
        
        @Published var routineParticipationStatus: MissionUserState?
        
        @Published var routineParticipationCount: Int = 0
        @Published var routinePoint: Int64 = 0
        
        /* Calendar Cell */
        // Total missions
        var isPointHistoryFetched: Bool = false
        @Published var participatedHistory: [PointHistory] = []
        @Published var participatedMissions: [any Mission] = []
        @Published var missionDates: [String] = []
        @Published var todayParticipation: Bool = false
        
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
        @Published var levelAllEvents: [any Mission] = [] {
            didSet {
                var dic: [Int64: [any Mission]] = [:]
                
                for mission in levelAllEvents {
                    if var array = dic[mission.missionPermitAvatarLevel] {
                        array.append(mission)
                        dic[mission.missionPermitAvatarLevel] = array
                        
                    } else {
                        dic[mission.missionPermitAvatarLevel] = [mission]
                    }
                }
                
                self.missionPerLevel = dic
            }
        }
        
        @Published var missionPerLevel: [Int64: [any Mission]] = [:] {
            didSet {
                
                /*
                if mission.level != nil {
                    // 레벨 셀 보여주기
                } else {
                    // 레벨 아닌 셀 보여주기
                }
                */
                var others: [(any Mission)?] = []
               
                others.append(nil)
                others.append(contentsOf: missionPerLevel[0] ?? [])
                others.append(contentsOf: missionPerLevel[1] ?? [])
                others.append(nil)
                others.append(contentsOf: missionPerLevel[2] ?? [])
                others.append(nil)
                others.append(contentsOf: missionPerLevel[3] ?? [])
                others.append(nil)
                others.append(contentsOf: missionPerLevel[4] ?? [])
                others.append(nil)
                others.append(contentsOf: missionPerLevel[5] ?? [])
                
                self.levelEvents.append(contentsOf: others)
            }
        }
        
        @Published var regularEvents: [any Mission] = []
        @Published var levelEvents: [(any Mission)?] = []
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
            async let _ = self.getSelectedRoutine()
            
            async let _ = self.createMissionMainViewViewModel()

            async let _ = self.getTodayRank()
            
            async let _ = self.getAllMissionBaseData()
           
        }
        
        self.getNumberOfParticipatedMissions()

    }
}

//MARK: - Fetch Data from FireStore
extension MyPageViewViewModel {

    private func sortMissionsTimeline(timeline: [String : [Timestamp]]) {
        let weeklyMissions = timeline.filter {
            $0.key.hasPrefix("weekly")
        }
        self.mission.weeklyMissions = weeklyMissions
        
        let dailyMissions = timeline.filter {
            $0.key.hasPrefix("daily")
        }
        self.mission.dailyMissions = dailyMissions
    }
    
    /// Get User Selected Routine Mission If Any.
    func getSelectedRoutine() async {
        self.getRoutineParticipationCount(type: .dailyExpGoodWorker)
    }
    
    /// Get Number of Pariticipated Days of Routine Missions.
    func getRoutineParticipationCount(type: MissionType) {
        Task {
            do {
                var todayInfo: [String: String] = [:]
                
                // 1. 선택한 루틴 미션DB 조회
                let missions = try await self.firestoreManager.getRoutineMission(type: type)
                let userMap = missions.compactMap { mission in
                    let statusMap = mission.missionUserStateMap
                    
                    // 금일 참여 현황 조회
                    if mission.missionId == Date().yearMonthDateFormat {
                        todayInfo = statusMap ?? [:]
                    }
                    
                    return statusMap
                    
                }
                
                let todayStatus = todayInfo[String(describing: self.user.userIndex)] ?? MissionUserState.notParticipated.rawValue
                self.mission.routineParticipationStatus = MissionUserState(rawValue: todayStatus) ?? .notParticipated

                // 2. 참여 현황 조회
                let currentUser = userMap.filter { map in
                    map.contains { ele in
                        ele.key == String(describing: self.user.userIndex)
                    }
                }
                
                self.mission.routineParticipationCount = currentUser.count

                // 4. 전체 포인트 계산 (5, 10, 15회는 500P)
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
    
    func getAllMissionBaseData() async {
        do {
            let results = try await firestoreManager.getAllMissionBaseData()
            self.mission.missionBaseInfo = results
        }
        catch {
            print("Error getting base mission data: \(error)")
        }
    }
    
    /// Get leveled events.
    func getLevelEvents() async {
        do {
            self.event.levelAllEvents = try await self.firestoreManager.getLevelEvents()
        }
        catch {
            print("Error fetching event missions -- \(error)")
        }
    }
    
    
    /// Get regular events.
    func getRegularEvents() async {
        do {
            self.event.regularEvents = try await self.firestoreManager.getRegularEvents()
        }
        catch {
            print("Error fetching event missions -- \(error)")
        }
    }
    
    func createMissionMainViewViewModel() async {

        let token = await self.getTopLevelNftToken() ?? "no-token"
        let nftUrl = await self.firestoreManager.getNft(tokenId: token)?.nftContentImageUrl ?? "no-url"
        let level = self.getUserLevel()
        
        print("Userlevel: \(level)")
        self.userProfileViewModel = UserProfileViewViewModel(
            profileImage: nftUrl,
            username: self.user.userNickname,
            points: self.user.userTotalPoint ?? 0,
            maxPoints: 15,
            level: level,
            timeLeft: self.hoursLeftUntilEndOfDay()
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
                
                // 3. Check if there is any participation on today.
                if date == Date().yearMonthDateFormat {
                    self.mission.todayParticipation = true
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
    
    private func getNumberOfParticipatedMissions() {
        let week1 = self.user.userTypeMissionArrayMap?["weekly_quiz__1"]?.count ?? 0
        let week2 = self.user.userTypeMissionArrayMap?["weekly_quiz__2"]?.count ?? 0
        let week3 = self.user.userTypeMissionArrayMap?["weekly_quiz__3"]?.count ?? 0
        self.mission.numberOfFinishedMissions.append(week1)
        self.mission.numberOfFinishedMissions.append(week2)
        self.mission.numberOfFinishedMissions.append(week3)
    }
    
}

// MARK: - NFT related logics
extension MyPageViewViewModel {
    
    func getTopLevelNftToken() async -> String? {
        let tokens = await self.updateUserOwnedNft()
        let topAvatarToken = self.sortTopLevelNft(tokens: tokens)
        let intToken = Int64(topAvatarToken ?? "0") ?? 0
        
        self.saveUserLevel(highestToken: intToken)
        
        return topAvatarToken
    }
    
    private func sortTopLevelNft(tokens: [String]) -> String? {
        let avatarTokens = tokens.filter {
            let tokenNum = Int64($0) ?? 0
            let range = NftLevel.avatar1.lowerBound...NftLevel.avatar5.upperBound
            return range.contains(tokenNum)
        }
        
        return avatarTokens.last
    }
    
    func updateUserOwnedNft() async -> [String] {
        
        do {
            // 1. Fetch NFTs from Luniverse.
            let token = try await LuniverseServiceManager.shared.requestAccessToken()
            let nfts = try await LuniverseServiceManager.shared.requestNftList(authKey: token,
                                                                               walletAddress: self.user.userWalletAddress ?? "n/a")
            
            let newestTokens: [String] = nfts.data.items.map { $0.tokenId }.reversed()
            
            // 2. Fetch NFTs from Firestore.
            let savedNfts = try UPlusUser.getCurrentUser().userNfts ?? []
            
            let savedTokens = savedNfts.compactMap { $0.path.extractAfterSlash() }
            
            logger.info("FireBase tokens: \(savedTokens)")
            logger.info("Luniverse tokens: \(newestTokens)")
            
            // 3. Compare differences.
            self.differences(savedTokens, newestTokens)

            return newestTokens
        }
        catch {
            logger.error("Error requesting Luniverse access token -- \(String(describing: error))")
            return []
        }
        
    }
    
    // user_nfts의 reference 업데이트
    private func updateNftList(nfts: [String], userIndex: Int64) {
        Task {
            do {
                try await firestoreManager.updateOwnedNfts(tokens: nfts)
    
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
//MARK: - Save Data to UserDefaults
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
    
    private func saveUserLevel(highestToken: Int64) {
        let level = NftLevel.level(tokenId: highestToken)
        UserDefaults.standard.set(level, forKey: UserDefaultsConstants.level)
    }
    
    func getUserLevel() -> Int64 {
        return Int64(UserDefaults.standard.integer(forKey: UserDefaultsConstants.level))
    }
    
}

//MARK: - Utilities
extension MyPageViewViewModel {

    private func differences(_ oldArr: [String], _ newArr: [String]) {
        let diffs = newArr.difference(from: oldArr)
        var newlyAddedNfts: [String] = []
        
        for diff in diffs {
            switch diff {
            case .remove(_, let element, _):
                self.logger.info("삭제된 NFT: \(element)")
                
            case .insert(_, let element, _):
                newlyAddedNfts.append(element)
                self.logger.info("새로 추가된 NFT: \(element)")
            }
        }
        
        self.updatedNfts = newlyAddedNfts
        self.updateNftList(nfts: newArr, userIndex: user.userIndex)
    }

    func timeDifference(from startDate: Date, to endDate: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour], from: startDate, to: endDate)

        guard let days = components.day, let hours = components.hour else {
            return String(format: MissionConstants.timeLeft, 0, 0)
        }

        return String(format: MissionConstants.timeLeft, days, hours)
    }
    
    private func hoursLeftUntilEndOfDay() -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        if let endOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now)?.addingTimeInterval(24 * 60 * 60) {
            let components = calendar.dateComponents([.hour], from: now, to: endOfDay)
            return components.hour ?? 0
        }
        
        return 0
    }
}

