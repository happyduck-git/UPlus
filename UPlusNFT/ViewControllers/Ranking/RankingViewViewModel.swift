//
//  RankingViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/24.
//

import Foundation
import Combine
import FirebaseFirestore

final class RankingViewViewModel {
    
    private let firestoreManager = FirestoreManager.shared
    
    //MARK: - Section
    enum TotalRankSection: CaseIterable {
        case top3
        case others
    }
    
    enum TodayRankSection: CaseIterable {
        case yesterday
        case today
    }
    
    let totalRankSections: [TotalRankSection] = TotalRankSection.allCases
    let todayRankSections: [TodayRankSection] = TodayRankSection.allCases
    
    //MARK: - Data
    private let currentUser: UPlusUser?
    
    @Published var totalRankerFetched: Bool = false
    
    @Published var todayRankerList: [UPlusUser] = []
    @Published var totalRankerList: [UPlusUser] = [] {
        didSet {
            let results = self.getTopNftOfUsers(users: totalRankerList)
            self.topNfts = results
        }
    }
    
    @Published var yesterdayRankerList: [UPlusUser] = []
    @Published var top3RankUserList: [UPlusUser] = [] {
        didSet {
            let results = self.getTopNftOfUsers(users: top3RankUserList)
            self.top3UserNfts = results
        }
    }
    @Published var exceptTop3RankerList: [UPlusUser] = []
    
    @Published var currentUserTodayRank: UPlusUser?
    @Published var currentUserTotalRank: UPlusUser?
    
    @Published var topNfts: [Int64: DocumentReference?] = [:]
    @Published var top3UserNfts: [Int64: DocumentReference?] = [:]
    
    init() {

        do {
            self.currentUser = try UPlusUser.getCurrentUser()
        }
        catch {
            print("Error getting saved user info from UserDefaults")
            self.currentUser = nil
            return
        }
        
    }
    
}

extension RankingViewViewModel {
    
    struct NftInfo {
        let ref: DocumentReference
        let tokenId: Int64
    }
    
    private func getTopNftOfUsers(users: [UPlusUser]) -> [Int64: DocumentReference?] {
        var refs: [Int64: DocumentReference?] = [:]
        
        for user in users {
            guard let nfts = user.userNfts else {
                refs[user.userIndex] = nil
                continue
            }
         
            let nftInfos = nfts.compactMap { ref -> NftInfo? in
                guard let extractedString = ref.path.extractAfterSlash(),
                      let tokenId = Int64(extractedString) else {
                    return nil
                }
                return NftInfo(ref: ref, tokenId: tokenId)
            }

            let filteredNftInfos = nftInfos.filter { NftLevel.level(tokenId: $0.tokenId) <= 5 }
            let maxNftInfo = filteredNftInfos.max { a, b in a.tokenId < b.tokenId }?.ref
            refs[user.userIndex] = maxNftInfo
        }
        return refs
    }
}

extension RankingViewViewModel {
    
    func getAllUserTotalPoint() async -> Bool {
        
        do {
            self.totalRankerList = try await self.firestoreManager.getAllUserTotalPoint()
            return true
        }
        catch {
            print("Error fetching all user points -- \(error)")
            return false
        }
        
    }
    
    func getTodayRankers(totalRankerList: [UPlusUser]) async throws {
        /*
        let todayPointHistory = try await self.firestoreManager.getTodayPointHistory()
        */
        let todayPointHistory = try await FirestoreActor.shared.getTodayPointHistory()
        
        var rankerList: [UPlusUser] = []
        
        for point in todayPointHistory {
            let index = point.userIndex ?? "no-user-index"
            
            for user in totalRankerList {
                var tempUser = user
                if String(describing: tempUser.userIndex) == index {
                    
                    if user.userPointHistory == nil {
                        tempUser.userPointHistory = [point]
                    } else {
                        tempUser.userPointHistory?.append(point)
                    }
                    rankerList.append(tempUser)
                }
            }
            
        }
                
        self.todayRankerList = rankerList
    }
    
    func getYesterdayRankers(totalRankerList: [UPlusUser]) async throws {
        let yesterdayPointHistory = try await self.firestoreManager.getYesterdayPointHistory()
        var rankerList: [UPlusUser] = []
        
        for point in yesterdayPointHistory {
            let index = point.userIndex ?? "no-user-index"
            
            for user in totalRankerList {
                var tempUser = user
                if String(describing: tempUser.userIndex) == index {
                    
                    if user.userPointHistory == nil {
                        tempUser.userPointHistory = [point]
                    } else {
                        tempUser.userPointHistory?.append(point)
                    }
                    rankerList.append(tempUser)
                }
            }
            
        }
        
        self.yesterdayRankerList = rankerList
        
    }
    
    func getRanking() {
        
        /* 오늘 점수 랭킹 */
        let todayRank = self.todayRankerList.filter {
            $0.userIndex == currentUser?.userIndex
        }.first
        
        self.currentUserTodayRank = todayRank
        
        /* 누적 점수 랭킹 */
        let totalRank = self.totalRankerList.filter {
            $0.userIndex == currentUser?.userIndex
        }.first
        self.currentUserTotalRank = totalRank
      
        /* 누적 TOP3 */
        self.top3RankUserList = self.getTopThreeRankers(list: self.totalRankerList)
        self.exceptTop3RankerList = self.getElementsExceptTopThree(list: self.totalRankerList)

    }

}

//MARK: - Private
extension RankingViewViewModel {
    private func getTopThreeRankers(list: [UPlusUser]) -> [UPlusUser] {
        if list.count >= 3 {
            return Array(list[0...2])
        } else {
            return list
        }
    }
    
    private func getElementsExceptTopThree(list: [UPlusUser]) -> [UPlusUser] {
        return Array(list.dropFirst(3))
    }

}

