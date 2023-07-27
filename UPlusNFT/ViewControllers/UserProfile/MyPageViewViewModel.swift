//
//  MyPageViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/26.
//

import Foundation
import FirebaseFirestore
import Combine

final class MyPageViewViewModel {
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    //MARK: - Sections
    enum MyPageViewSectionType: CaseIterable {
        case profile
        case myNfts
    }
    
    let sections: [MyPageViewSectionType] = MyPageViewSectionType.allCases
    
    //MARK: - Combine
    @Published var todayRank2: Int = UPlusServiceInfoConstant.totalMembers
    
    //MARK: - Properties
    let user: UPlusUser
//    let userNfts: [DocumentReference]
//    let username: String
//    let ownedPoints: Int64
//    let userDailyRank: Int64
//    let numberOfownedRewards: Int64
    let todayRank: Int
    
    init(user: UPlusUser,
         todayRank: Int
//         , userNfts: [DocumentReference], username: String, ownedPoints: Int64, userDailyRank: Int64, numberOfownedRewards: Int64, todayRank: Int
    ) {
        self.user = user
//        self.userNfts = userNfts
//        self.username = username
//        self.ownedPoints = ownedPoints
//        self.userDailyRank = userDailyRank
//        self.numberOfownedRewards = numberOfownedRewards
        self.todayRank = todayRank
        
        self.getTodayRank(of: String(describing: user.userIndex))
    
    }
}

//MARK: - Fetch Data from FireStore
extension MyPageViewViewModel {
    func getTodayRank(of userIndex: String) {
        Task {
            
            do {
                let results = try await firestoreManager.getAllUserTodayPoint()
                let rank = results.firstIndex {
                    return String(describing: $0.userIndex) == userIndex
                } ?? (UPlusServiceInfoConstant.totalMembers - 1)
                self.todayRank2 = rank + 1
            }
            catch {
                print("Error getting today's points: \(error)")
            }
            
        }
    }
}
