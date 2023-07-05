//
//  Recomment.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/23.
//

import Foundation
import FirebaseFirestore

struct Recomment: Hashable {
    let commentId: String
    let recommentAuthorUid: String
    let recommentContentText: String
    let recommentCreatedTime: Timestamp
    let recommentId: String
}
