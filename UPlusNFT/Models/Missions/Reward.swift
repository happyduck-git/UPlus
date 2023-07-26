//
//  Reward.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/24.
//

import Foundation

struct Reward: Codable, Hashable {
     let rewardIndex: Int64 // 다큐먼트의 ID와 동일
     let rewardType: String
     let rewardName: String?
     let rewardImagePath: String?
     let rewardUser: String? // 보상 아이템을 획득한 사용자의 다큐먼트
}
