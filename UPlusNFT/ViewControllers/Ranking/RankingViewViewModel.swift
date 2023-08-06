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
    
    private let currentUser: UPlusUser?
    
    @Published var todayRankList: [UPlusUser] = []
    @Published var totalRankUserList: [UPlusUser] = []
    @Published var yesterDayRankUserList: [UPlusUser] = []
    @Published var top3RankUserList: [UPlusUser] = []
    
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
    
    func getUserPoints() {
        Task {
            do {
                let points = try await self.firestoreManager.getTodayPointHistoryPoint()
                let totalUsers = try await self.firestoreManager.getAllUserTotalPoint()
                self.totalRankUserList = totalUsers
                
                var todayRankList: [UPlusUser] = []
                var yesterdayRankList: [UPlusUser] = []
                
                let currentDate = Date()
                let calendar = Calendar.current
                guard let yesterday = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                    return
                }
                
                /* 점수 리스트 */
                for user in totalUsers {
                    let userIndex = user.userIndex
                    
                    for point in points {
                        let index = point.userIndex ?? "no-user-index"
                        
                        if String(describing: userIndex) == index {
                            var user = user
                        
                            if user.userPointHistory == nil {
                                user.userPointHistory = [point]
                            } else {
                                user.userPointHistory?.append(point)
                            }
                        }
                        
                        /* 어제, 오늘 점수 리스트 */
                        if point.userPointTime == currentDate.yearMonthDateFormat {
                            // Today's points
                            todayRankList.append(user)
                            
                        } else if point.userPointTime == yesterday.yearMonthDateFormat {
                            // Yesterday's points
                            yesterdayRankList.append(user)
                        } else {
                            continue
                        }
                    }
                    
                }
                
                self.todayRankList = todayRankList
                self.yesterDayRankUserList = yesterdayRankList
                
                /* 오늘 점수 랭킹 */
                let todayRank = self.todayRankList.filter {
                    $0.userIndex == currentUser?.userIndex
                }.first
                
                self.currentUserTodayRank = todayRank
                
                /* 누적 점수 랭킹 */
                let totalRank = self.totalRankUserList.filter {
                    $0.userIndex == currentUser?.userIndex
                }.first
                self.currentUserTotalRank = totalRank
                
                /* 누적 TOP3 */
                self.top3RankUserList = self.getTopThreeRankers(list: self.todayRankList)
            }
            catch {
                print("Error fetching -- \(error)")
            }
        }
    }
    
    private func getTopThreeRankers(list: [UPlusUser]) -> [UPlusUser] {
        if list.count >= 3 {
            return Array(list[0...2])
        } else {
            return list
        }
    }
}
