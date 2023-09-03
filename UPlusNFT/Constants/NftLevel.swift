//
//  NftLevel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/14.
//

import Foundation

struct NftLevel {
    typealias PointRange = ClosedRange<Int64>

    static let avatar1: PointRange = 000_000_000...000_009_999
    static let avatar2: PointRange = 000_010_000...000_019_999
    static let avatar3: PointRange = 000_020_000...000_029_999
    static let avatar4: PointRange = 000_030_000...000_039_999
    static let avatar5: PointRange = 000_040_000...000_049_999
    
    static let athelete: PointRange =  001_000_000...001_009_999
    static let goodWorker: PointRange =  001_010_000...001_019_999
    static let environment: PointRange =  001_020_000...001_029_999
    
    static let weekly1: PointRange =  002_000_000...002_009_999
    static let weekly2: PointRange =  002_010_000...002_019_999
    static let weekly3: PointRange =  002_020_000...002_029_999
    
    static let gift: PointRange =  003_000_000...003_009_999
    
    static let raffleBronze: PointRange =  003_010_000...003_019_999
    static let raffleSilver: PointRange =  003_020_000...003_029_999
    static let raffleGold: PointRange =  003_030_000...003_039_999

}

extension NftLevel {
    static func level(tokenId: Int64) -> Int {
        switch tokenId {
        case avatar1:
            return 1
        case avatar2:
            return 2
        case avatar3:
            return 3
        case avatar4:
            return 4
        case avatar5:
            return 5
            
        case weekly1, weekly2, weekly3:
            return 10
      
        // gift and raffles
        default:
            return 100
        }
    }
    
    static func name(tokenId: Int64) -> String {
        switch tokenId {
        case avatar1:
            return "Level.1"
        case avatar2:
            return "Level.2"
        case avatar3:
            return "Level.3"
        case avatar4:
            return "Level.4"
        case avatar5:
            return "Level.5"
            
        case weekly1, weekly2, weekly3:
            return "여정 인증서"
      
        case goodWorker:
            return "경험 인증서"
        // gift and raffles
        default:
            return "선물권"
        }
    }
    
    static func image(tokenId: Int64) -> String {
        switch tokenId {
        case avatar1:
            return "avatar-level1"
        case avatar2:
            return "avatar-level2"
        case avatar3:
            return "avatar-level3"
        case avatar4:
            return "avatar-level4"
        case avatar5:
            return "avatar-level5"
            
        case weekly1:
            return "nft-week1"
        case weekly2:
            return "nft-week2"
        case weekly3:
            return "nft-week3"
        case goodWorker:
            return "nft-routine"
            
        // gift and raffles
        default:
            return "gift-icon"
        }
    }
}
