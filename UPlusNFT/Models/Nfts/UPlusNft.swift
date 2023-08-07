//
//  UPlusNft.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/04.
//

import Foundation
import FirebaseFirestore

enum UPlusNftType: String {
    case avatar
    case expAuth = "exp_auth"
    case journeyAuth = "journey_auth"
    case raffle
}

enum UPlusNftDetailType: String {
    case avatar = "avatar__level_%"
    case athlete = "exp_auth__athlete"
    case goodWorker = "exp_auth__good_worker"
    case environmentalist = "exp_auth__environmentalist"
    case journey = "journey_auth__%"
    case raffle
}

struct UPlusNft: Codable {
    let nftTokenId: Int64
    let nftMetadataUrl: String
    let nftContentImageUrl: String
    let nftType: String
    let nftDetailType: String
    let nftTradable: Bool
    let nftUser: DocumentReference?
}
