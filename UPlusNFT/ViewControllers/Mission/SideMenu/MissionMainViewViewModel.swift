//
//  MissionMainViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/18.
//

import Foundation

final class MissionMainViewViewModel {
    
    // STH holder인지 확인.
    var isHolder: Bool = false
    
    /* Mission Profile Section */
    let profileImage: String
    let username: String
    let points: Int64
    let maxPoints: Int64
    let level: Int64
    
    /* Todday Mission Section */
    let numberOfMissions: Int64
    let timeLeft: Int64
    
    /* Daily Quiz Section */
    let quizTitle: String
    let quizDesc: String
    let quizPoint: Int64
    
    init(profileImage: String,
         username: String,
         points: Int64,
         maxPoints: Int64,
         level: Int64,
         numberOfMissions: Int64,
         timeLeft: Int64,
         quizTitle: String,
         quizDesc: String,
         quizPoint: Int64
    ) {
        self.profileImage = profileImage
        self.username = username
        self.points = points
        self.maxPoints = maxPoints
        self.level = level
        self.numberOfMissions = numberOfMissions
        self.timeLeft = timeLeft
        self.quizTitle = quizTitle
        self.quizDesc = quizDesc
        self.quizPoint = quizPoint
    }
    
}
