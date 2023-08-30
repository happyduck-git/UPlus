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
    let timeLeft: Int
    var daysLeft: Int = 0
    
    init(profileImage: String,
         username: String,
         points: Int64,
         maxPoints: Int64,
         level: Int64,
         timeLeft: Int
    ) {
        self.profileImage = profileImage
        self.username = username
        self.points = points
        self.maxPoints = maxPoints
        self.level = level
        self.timeLeft = timeLeft
        
        self.daysLeft = self.calculateDaysLeft()
    }
    
}

extension UserProfileViewViewModel {
    private func calculateDaysLeft() -> Int {
        
        let calendar = Calendar.current
        let today = Date()
        guard let todayWeekday = calendar.dateComponents([.weekday], from: today).weekday else { return -1 }
        
        // In the Gregorian calendar, Sunday is 1 and Saturday is 7. So, Friday is 6.
        let friday = 6
        
        if todayWeekday <= friday {
            return friday - todayWeekday + 1
        } else {
            return 7 - todayWeekday + friday + 1
        }
        
    }
}
