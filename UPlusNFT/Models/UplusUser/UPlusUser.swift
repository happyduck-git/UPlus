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
    let userAccountCreationTime: Timestamp?
    var userTotalPoint: Int64?
    let userHasVipNft: Bool
    var userRewards: [DocumentReference]? // 사용자가 획득한 보상 아이템 다큐먼트를 배열로 갖는다.
    var userNfts: [DocumentReference]? //사용자가 획득한 NFT 다큐먼트를 배열로 갖는다.
    let userTypeMissionArrayMap: [String: [DocumentReference]]? //사용자가 참여한 미션 다큐먼트를 map으로 갖는다.
    var userPointHistory: [PointHistory]?
    let userIsAdmin: Bool
    
}

extension UPlusUser {
    
    static func saveCurrentUser(email: String) async throws -> Self {
        let currentUser = try await FirestoreManager.shared.getCurrentUserInfo(email: email)

        let codablePointHistory = currentUser.userPointHistory?.map { pointHistory in
            SwiftPointHistory(
                userIndex: pointHistory.userIndex,
                userPointTime: pointHistory.userPointTime,
                userPointCount: pointHistory.userPointCount,
                userPointMissions: pointHistory.userPointMissions?.map { $0.path }
            )
        }
        
        // Convert UPlusUser to SwiftUPlusUser
        let path = currentUser.userTypeMissionArrayMap?.mapValues({ refList in
            refList.map{ $0.path }
        })
            let codableUser = SwiftUPlusUser(
                userIndex: currentUser.userIndex,
                userUid: currentUser.userUid,
                userEmail: currentUser.userEmail,
                userNickname: currentUser.userNickname,
                userWalletAddress: currentUser.userWalletAddress,
                userAccountCreationTime: currentUser.userAccountCreationTime,
                userTotalPoint: currentUser.userTotalPoint,
                userHasVipNft: currentUser.userHasVipNft,
                userRewards: currentUser.userRewards?.map { $0.path },
                userNfts: currentUser.userNfts?.map { $0.path },
                userTypeMissionArrayMap: path,
                userPointHistory: codablePointHistory,
                userIsAdmin: currentUser.userIsAdmin
            )
        let encodedUserData = try JSONEncoder().encode(codableUser)
        UserDefaults.standard.setValue(encodedUserData, forKey: UserDefaultsConstants.currentUser)
        /*
        #if DEBUG
        print("User Info Saved: \(codableUser)")
        #endif
        */
        return currentUser
    }
    
    static func getCurrentUser() throws -> Self {
        guard let data = UserDefaults.standard.object(forKey: UserDefaultsConstants.currentUser) as? Data,
              let user = try? JSONDecoder().decode(SwiftUPlusUser.self, from: data)
        else {
            print("Error getting saved user info from UserDefaults")
            throw UPlusUserError.noUserSaved
        }

        return UPlusUser.convertToUPlusUser(user)
    }
    
    static func updateUser(_ user: Self) throws {
        let codableUser = user.convertToSwiftUser()
        let encodedUserData = try JSONEncoder().encode(codableUser)
        UserDefaults.standard.setValue(encodedUserData, forKey: UserDefaultsConstants.currentUser)

        #if DEBUG
//        print("User Info Updated: \(codableUser)")
        #endif

    }
    
    private func convertToSwiftUser() -> SwiftUPlusUser {
        let codablePointHistory = self.userPointHistory?.map { pointHistory in
            SwiftPointHistory(
                userIndex: pointHistory.userIndex,
                userPointTime: pointHistory.userPointTime,
                userPointCount: pointHistory.userPointCount,
                userPointMissions: pointHistory.userPointMissions?.map { $0.path }
            )
        }
        
        let path = self.userTypeMissionArrayMap?.mapValues({ refList in
            refList.map{ $0.path }
        })
        
        // Convert UPlusUser to SwiftUPlusUser
        return SwiftUPlusUser(
            userIndex: self.userIndex,
            userUid: self.userUid,
            userEmail: self.userEmail,
            userNickname: self.userNickname,
            userWalletAddress: self.userWalletAddress,
            userAccountCreationTime: self.userAccountCreationTime,
            userTotalPoint: self.userTotalPoint,
            userHasVipNft: self.userHasVipNft,
            userRewards: self.userRewards?.map { $0.path },
            userNfts: self.userNfts?.map { $0.path },
            userTypeMissionArrayMap: path,
            userPointHistory: codablePointHistory,
            userIsAdmin: self.userIsAdmin
        )
    }
    
    private static func convertToUPlusUser(_ user: SwiftUPlusUser) -> UPlusUser {
        
        let firestore = Firestore.firestore()
        let userRewards = user.userRewards?.map { firestore.document($0) }
        let userNfts = user.userNfts?.map { firestore.document($0) }
        let userTypeMissionArrayMap = user.userTypeMissionArrayMap?.compactMapValues({ refList in
            refList.map { firestore.document($0) }
        })
        let pointHistory = user.userPointHistory?.map { swiftPointHistory in
            PointHistory(
                userIndex: swiftPointHistory.userIndex,
                userPointTime: swiftPointHistory.userPointTime,
                userPointCount: swiftPointHistory.userPointCount,
                userPointMissions: swiftPointHistory.userPointMissions?.map { firestore.document($0) }
            )
        }
        
        return UPlusUser(
                userIndex: user.userIndex,
                userUid: user.userUid,
                userEmail: user.userEmail,
                userNickname: user.userNickname,
                userWalletAddress: user.userWalletAddress,
                userAccountCreationTime: user.userAccountCreationTime,
                userTotalPoint: user.userTotalPoint,
                userHasVipNft: user.userHasVipNft,
                userRewards: userRewards,
                userNfts: userNfts,
                userTypeMissionArrayMap: userTypeMissionArrayMap,
                userPointHistory: pointHistory,
                userIsAdmin: user.userIsAdmin
            )
    }
    
    enum UPlusUserError: Error {
        case noUserSaved
    }
}

struct SwiftUPlusUser: Codable {
    let userIndex: Int64
    let userUid: String?
    let userEmail: String
    let userNickname: String
    let userWalletAddress: String?
    let userAccountCreationTime: Timestamp?
    let userTotalPoint: Int64?
    let userHasVipNft: Bool
    let userRewards: [String]?
    let userNfts: [String]?
    let userTypeMissionArrayMap: [String: [String]]?
    var userPointHistory: [SwiftPointHistory]?
    let userIsAdmin: Bool
}

struct PointHistory: Codable {

    var userIndex: String?
    
    let userPointTime: String //사용자가 포인트를 획득한 날짜를 가리킨다. 날짜와는 다르게 시각은 항상 00시 00분을 가리킨다.
    var userPointCount: Int64 //사용자가 해당일 획득한 포인트의 총량을 가리킨다.
    var userPointMissions: [DocumentReference]?
}

// 누적 랭킹: userPointHistory.map { //upserPointCount 총합 } 반영
// 일일 랭킹: userPointHistory에서 userPointTime이 당일인 경우의 userPointCount 반영
// 어제의 랭킹: userPointHistory에서 userPointTime이 (당일 - 1)인 경우의 userPointCount 반영

struct SwiftPointHistory: Codable {
    var userIndex: String?
    let userPointTime: String
    let userPointCount: Int64
    let userPointMissions: [String]?
}
