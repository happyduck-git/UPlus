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
    
    @Published var userList: [UPlusUser] = []
    
}

extension RankingViewViewModel {
    
    func getUserRanking() {
        Task {
            do {
                self.userList = try await self.firestoreManager.getUsers()
                print("Users: \(self.userList)")
            }
            catch {
                print("Error fetching users -- \(error)")
            }
        }
    }
    
}
