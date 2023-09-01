//
//  ArchiveWallet.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/23.
//

import Foundation

struct ArchiveWallet: WalletProtocol, Codable {
    let address: String
    
    init(address: String) {
        self.address = address
    }
}
