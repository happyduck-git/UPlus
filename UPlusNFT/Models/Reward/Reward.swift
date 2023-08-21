//
//  Reward.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/24.
//

import Foundation
import FirebaseFirestore

struct Reward: Codable, Hashable {
     let rewardIndex: Int64 // 다큐먼트의 ID와 동일
     let rewardType: String
     let rewardName: String?
     let rewardImagePath: String?
     let rewardUser: [DocumentReference]?
}

struct RewardType {
    typealias PointRange = ClosedRange<Int>
    
    static let coffeeCoupon: PointRange = 0...999
    static let coffeePoint10K: PointRange = 1000...1999
    static let coffeePoint20K: PointRange = 2000...2999
}

extension RewardType {
    
    static func fieldName(coupon index: Int) -> String {
        switch index {
        case coffeeCoupon:
            return "goods__coffee_exchange"
            
        case coffeePoint10K:
            return "goods__coffee_point_10000"
            
        case coffeePoint20K:
            return "goods__coffee_point_20000"
            
        default:
            return "no_reward"
            
        }
    }
    
}
