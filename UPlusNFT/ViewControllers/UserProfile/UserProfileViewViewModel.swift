//
//  MissionMainViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/18.
//

import Foundation
import Combine

final class UserProfileViewViewModel {
    // MARK: - Porperties
    
    /* Mission Profile Section */
    let profileImage: String
    let username: String
    let points: Int64
    let maxPoints: Int64
    let level: Int64
    
    /* Today Mission Section */
    let timeLeft: Int64
    
    init(profileImage: String,
         username: String,
         points: Int64,
         maxPoints: Int64,
         level: Int64,
         timeLeft: Int64
    ) {
        self.profileImage = profileImage
        self.username = username
        self.points = points
        self.maxPoints = maxPoints
        self.level = level
        self.timeLeft = timeLeft
    }
    
}
