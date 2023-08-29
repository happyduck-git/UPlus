//
//  OnBoardingViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/29.
//

import Foundation

final class OnBoardingViewViewModel {
    
    private let firestoreManager = FirestoreManager.shared
    
    var isTapped: Bool = false
    @Published var numberOfUsers: Int = 0
    
    // MARK: - Init
    init() {
        self.getTotalNumberOfUsers()
    }
    
}

extension OnBoardingViewViewModel {
    
    private func getTotalNumberOfUsers() {
        Task {
            do {
                self.numberOfUsers = try await firestoreManager.getNumberOfRegisteredUsers()
            }
            catch {
                UPlusLogger.logger.error("Error fetching number of registered users. -- \(String(describing: error))")
            }
        }
        
    }
    
}
