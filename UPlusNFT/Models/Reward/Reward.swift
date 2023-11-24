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

// MARK: - Reward Type
enum RewardType: String {
    case coffeeCoupon1, coffeeCoupon2 = "goods__coffee_exchange"
    case coffeePoint10K = "goods__coffee_point_10000"
    case coffeePoint20K = "goods__coffee_point_20000"

    func couponIndex(userIndex: Int64) -> Int64 {
        switch self {
        case .coffeeCoupon1:
            return userIndex
        case .coffeeCoupon2:
            return userIndex + 3000
        case .coffeePoint10K:
            return userIndex + 1000
        case .coffeePoint20K:
            return userIndex + 2000
        }
    }
}

// MARK: - Reward Point Range
struct RewardRangePerType {
    typealias PointRange = ClosedRange<Int>
    
    static let coffeeCoupon1: PointRange = 0...999
    static let coffeePoint10K: PointRange = 1000...1999
    static let coffeePoint20K: PointRange = 2000...2999
    static let coffeeCoupon2: PointRange = 3000...3999
}

extension RewardRangePerType {
    
    static func fieldName(coupon index: Int) -> String {
        switch index {
        case coffeeCoupon1, coffeeCoupon2:
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
