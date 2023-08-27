//
//  SignUpCompleteViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/04.
//

import Foundation
import Combine

final class SignUpCompleteViewViewModel {
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - Data
//    @Published var welcomeNftImage: String?
    @Published var nickname: String?
    
    // MARK: - Init
    init() {
        self.getMembershipNft()
    }
}

extension SignUpCompleteViewViewModel {
    
    private func getMembershipNft() {
        Task {
            do {
                let user = try UPlusUser.getCurrentUser()
                
                self.nickname = user.userNickname
                /*
                self.welcomeNftImage = try await self.firestoreManager
                    .getMemberNft(userIndex: user.userIndex,
                                  isVip: user.userHasVipNft)
                
                print("Welcome nft image: \(self.welcomeNftImage ?? "no-image")")
                 */
            }
            catch {
                print("Error fetching nft url -- \(error)")
            }
        }
    }
    
}
