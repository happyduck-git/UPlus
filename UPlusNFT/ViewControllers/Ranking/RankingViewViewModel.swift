//
//  RankingViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/24.
//

import Foundation
import Combine

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
    
    @Published var totakRankerFetched: Bool = false
    
    @Published var todayRankerList: [UPlusUser] = []
    @Published var totalRankerList: [UPlusUser] = []
    
    @Published var yesterdayRankerList: [UPlusUser] = []
    @Published var top3RankUserList: [UPlusUser] = []
    @Published var exceptTop3RankerList: [UPlusUser] = []
    
    @Published var currentUserTodayRank: UPlusUser?
    @Published var currentUserTotalRank: UPlusUser?
    
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

