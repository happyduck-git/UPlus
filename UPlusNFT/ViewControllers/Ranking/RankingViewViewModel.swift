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
                
                let today = Date()
                let calendar = Calendar.current
                guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
                    return
                }
                
                /* 점수 리스트 */
                for user in totalUsers {
                    let userIndex = user.userIndex
                    
                    for point in points {
                        let index = point.userIndex ?? "no-user-index"
                        
                        var tempUser = user
                        
                        if String(describing: userIndex) == index {
                            
                            if user.userPointHistory == nil {
                                tempUser.userPointHistory = [point]
                            } else {
                                tempUser.userPointHistory?.append(point)
                            }
                            
                            /* 어제, 오늘 점수 리스트 */
                            if point.userPointTime == today.yearMonthDateFormat {
                                // Today's points
                                todayRankList.append(tempUser)
                                
                            } else if point.userPointTime == yesterday.yearMonthDateFormat {
                                // Yesterday's points
                                yesterdayRankList.append(tempUser)
                            } else {
                                continue
                            }
                        }
                        
                    }
                    
                }
                
                let sorted = todayRankList.sorted { $0.userPointHistory?.first?.userPointCount ?? 0 > $1.userPointHistory?.first?.userPointCount ?? 0 }

                self.todayRankList = sorted
                
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
