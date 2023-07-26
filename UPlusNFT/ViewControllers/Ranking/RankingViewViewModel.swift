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
    @Published var currentUserTodayRank: UPlusUser?
    @Published var currentUserTotalRank: UPlusUser?
    
    init() {
        guard let data = UserDefaults.standard.object(forKey: UserDefaultsConstants.currentUser) as? Data,
              let user = try? JSONDecoder().decode(UPlusUser.self, from: data)
        else {
            print("Error getting saved user info from UserDefaults")
            self.currentUser = nil
            return
        }
        self.currentUser = user
    }
    
}

extension RankingViewViewModel {
    
    func getTodayRanking() {
        Task {
            do {
                self.todayRankList = try await self.firestoreManager.getAllUserTodayPoint()

                let userRank = self.todayRankList.filter {
                    $0.userIndex == currentUser?.userIndex
                }.first
                
                self.currentUserTodayRank = userRank
            }
            catch {
                print("Error fetching users -- \(error)")
            }
        }
    }
    
    func getTotalRanking() {
        Task {
            do {
                self.totalRankUserList = try await self.firestoreManager.getAllUserTotalPoint()
                
                let userRank = self.totalRankUserList.filter {
                    $0.userIndex == currentUser?.userIndex
                }.first
                
                self.currentUserTotalRank = userRank
            }
            catch {
                print("Error fetching users -- \(error)")
            }
        }
    }
    
}
