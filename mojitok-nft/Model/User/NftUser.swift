//
//  User.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/05/26.
//

import Foundation

struct NftUser: Codable {
    let id: String
    var wallets: [ArchiveWallet]
    var socialAccount: ArchiveAccount?
    var arts: [ArchiveArt]
    
    init() {
        self.id = UUID().uuidString
        self.wallets = []
        self.socialAccount = nil
        self.arts = []
    }
    
    private init(wallets: [ArchiveWallet], socialAccount: ArchiveAccount, arts: [ArchiveArt]) {
        self.id = UUID().uuidString
        self.wallets = wallets
        self.socialAccount = socialAccount
        self.arts = arts
    }
}
