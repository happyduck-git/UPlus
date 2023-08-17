//
//  UPlusLevel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/14.
//

import Foundation

enum UserLevelPoint {
    typealias PointRange = ClosedRange<Int64>
    
    static let level1:PointRange = 0...399
    static let level2:PointRange = 400...899
    static let level3:PointRange = 900...1599
    static let level4:PointRange = 1600...2599
    static let level5:PartialRangeFrom<Int64> = 2600...
    
}

extension UserLevelPoint {
    static func level(forPoints points: Int64) -> Int {
        switch points {
        case level1:
            return 1
        case level2:
            return 2
        case level3:
            return 3
        case level4:
            return 4
        case level5:
            return 5
        default:
            return 99
        }
    }

    typealias Updates = (update: Bool, newLevel: Int)
    static func checkLevelUpdate(currentLevel: Int,
                                 newPoints: Int64) -> Updates {
        let newLevel = UserLevelPoint.level(forPoints: newPoints)
        if currentLevel == newLevel {
            return (true, currentLevel)
        } else {
         return (false, newLevel)
        }
    }
    
}

enum UserLevel: Int {
    case level1 = 1
    case level2 = 2
    case level3 = 3
    case level4 = 4
    case level5 = 5
    
    var coupon: String {
        switch self {
        case .level1:
            return " "
        case .level2:
            return "커피쿠폰 1장"
        case .level3:
            return "커피쿠폰 1장"
        case .level4:
            return "커피 1만원권"
        case .level5:
            return "커피 2만원권"
        }
    }
    
    var raffle: String {
        switch self {
        case .level1:
            return "1"
        case .level2:
            return "2"
        case .level3:
            return "3"
        case .level4:
            return "4"
        case .level5:
            return "5"
        }
    }
}
