//
//  GameUser.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/09/04.
//

import Foundation
import FirebaseFirestore

struct GameUser {
    let ownerAddress: String
    let actionCount: Int64
    let popScore: Int64
    let profileImageUrl: String
    let userIndex: String
    let ownedNFTs: [DocumentReference]?
}

