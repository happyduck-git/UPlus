//
//  Reward.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/24.
//

import Foundation

struct Reward: Codable {
     let rewardIndex: Int64
     let rewardType: String
     let rewardName: String?
     let rewardImagePath: String?
     let rewardUser: String?
}
