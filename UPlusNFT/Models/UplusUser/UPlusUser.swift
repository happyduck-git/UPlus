//
//  UPlusUser.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/24.
//

import Foundation
import FirebaseFirestore

struct UPlusUser: Codable {
    
    let userIndex: Int64 // 사용자에 부여한 고유한 순차 인덱스를 가리킨다. 다큐먼트 ID와 동일한 값을 갖는다. 이 값은 UID를 대신하여 사용자를 구분하는 키가 된다. 또한 사용자 별로 구분되는 NFT를 예약하기 위하여 순서를 갖는 숫자가 사용되었다.
    
    let userUid: String? //생성된 계정 UID.
    let userEmail: String
    let userNickname: String
    let userWalletAddress: String?
    let userAccountCreationTime: Timestamp? //사용자가 계정 생성을 수행한 날짜를 가리킨다.
    let userTotalPoint: Int64?
    let userHasVipNft: Bool
    let userRewards: [DocumentReference]? // 사용자가 획득한 보상 아이템 다큐먼트를 배열로 갖는다.
    let userNfts: [DocumentReference]? //사용자가 획득한 NFT 다큐먼트를 배열로 갖는다.
    let user_type_mission_array_map: [String: String]?
    let userMissions: [String]? //사용자가 참여한 미션 다큐먼트를 배열로 갖는다.
    var userPointHistory: [PointHistory]?
    let userIsAdmin: Bool
    
}

struct PointHistory: Codable {
    
    // 사용자가 일별로 획득한 포인트 량을 다큐먼트로 갖는다. 다큐먼트 ID는 YYYYMMDD와 같은 ID를 갖는다.
    
    var userIndex: String?
    
    let userPointTime: String //사용자가 포인트를 획득한 날짜를 가리킨다. 날짜와는 다르게 시각은 항상 00시 00분을 가리킨다.
    let userPointCount: Int64 //사용자가 해당일 획득한 포인트의 총량을 가리킨다.
    let userPointMissions: [DocumentReference]?
}

// 누적 랭킹: userPointHistory.map { //upserPointCount 총합 } 반영
// 일일 랭킹: userPointHistory에서 userPointTime이 당일인 경우의 userPointCount 반영
// 어제의 랭킹: userPointHistory에서 userPointTime이 (당일 - 1)인 경우의 userPointCount 반영
