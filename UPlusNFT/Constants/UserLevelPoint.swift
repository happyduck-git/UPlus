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
    static private func checkLevelUpdate(currentLevel: Int,
                                 newPoints: Int64) -> Updates {
        let newLevel = UserLevelPoint.level(forPoints: newPoints)
        print("Current level: \(currentLevel)")
        print("To be changed level: \(newLevel)")
        if currentLevel != newLevel {
            return (true, newLevel)
        } else {
         return (false, currentLevel)
        }
    }
    
}

extension UserLevelPoint {

    static func userLevelUpdate(mission: any Mission,
                                nftType: UPlusNftType,
                                firestoreManager: FirestoreManager,
                                nftServiceManager: NFTServiceManager) async throws {
        
        let level = UserDefaults.standard.value(forKey: UserDefaultsConstants.level) as? Int
        let user = try UPlusUser.getCurrentUser()
        let totalPoints = user.userTotalPoint ?? mission.missionRewardPoint
        
        let result = UserLevelPoint.checkLevelUpdate(
            currentLevel: level ?? UserLevelPoint.level(forPoints: totalPoints),
            newPoints: totalPoints
        )
        print("Total Points: \(totalPoints)")
        if result.update {
            do {
                print("Update level update, called. for userindex: \(user.userIndex), level: \(result.newLevel)")
                let newLevelResult = try await nftServiceManager.requestSingleNft(userIndex: user.userIndex,
                                                                                  nftType: .avatar,
                                                                                  level: result.newLevel)
                
                print("newLevelResult result: \(newLevelResult.data)")
                // 레벨 별 차등지급 상품
                var raffleType: UPlusNftDetailType?
                var coffeeType: RewardType?
                
                switch result.newLevel {
                case 2:
                    raffleType = .gift
                    coffeeType = .coffeeCoupon1
                case 3:
                    raffleType = .raffleBronze
                    coffeeType = .coffeeCoupon2
                case 4:
                    raffleType = .raffleSilver
                    coffeeType = .coffeePoint10K
                case 5:
                    raffleType = .raffleGold
                    coffeeType = .coffeePoint20K
                default:
                    raffleType = .gift
                    coffeeType = .coffeeCoupon1
                }
           
                let giftResult = try await nftServiceManager.requestSingleNft(userIndex: user.userIndex,
                                                                              nftType: raffleType ?? .gift)
                
                UPlusLogger.logger.info("Gift result: \(String(describing: giftResult.data))")
                UPlusLogger.logger.info("CoffeeType: \(String(describing: coffeeType?.rawValue))")
                UPlusLogger.logger.info("RaffleType: \(String(describing: raffleType?.rawValue))")
                
                try await firestoreManager.saveReward(userIndex: user.userIndex, reward: coffeeType ?? .coffeeCoupon1)
               
                UPlusLogger.logger.info("There is level update from \(String(describing: level)) to \(String(describing: result.newLevel)).")
            }
            catch {
                UPlusLogger.logger.error("Error requesting single nft -- \(String(describing: error))")
            }
            
        } else {
            UPlusLogger.logger.info("There is no level update.")
        }
    }
     
}

// MARK: - User Level
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
    
    var scoreRange: ClosedRange<Int64> {
        switch self {
        case .level1:
            return 0...399
        case .level2:
            return 400...899
        case .level3:
            return 900...1599
        case .level4:
            return 1600...2599
        case .level5:
            return 2600...9999
        }
    }
}
