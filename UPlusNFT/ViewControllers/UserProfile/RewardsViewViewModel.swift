//
//  RewardsViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/24.
//

import Foundation

final class RewardsViewViewModel {
    
    private let firestoreManager = FirestoreManager.shared
    
    @Published var rewards: [Reward] = []
    
}

extension RewardsViewViewModel {
    func getRewardsOwned(by ownerIndex: String) {
        Task {
            do {
                self.rewards = try await self.firestoreManager.getRewardsOwned(by: ownerIndex)
            }
            catch {
                print("Error fetching rewards -- \(error)")
            }
        }
    }
}
