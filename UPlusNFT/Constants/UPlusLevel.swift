//
//  UPlusLevel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/14.
//

import Foundation

enum UPlusLevel {
    typealias PointRange = ClosedRange<Int64>
    
    static let level1:PointRange = 0...399
    static let level2:PointRange = 400...899
    static let level3:PointRange = 900...1599
    static let level4:PointRange = 1600...2599
    static let level5:PartialRangeFrom<Int64> = 2600...
    
}

extension UPlusLevel {
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
}
