//
//  WalletViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/04.
//

import Foundation

final class WalletViewViewModel {
    
    var numberOfNfts: Int = 0
    var walletAddress: String
    var nfts: [UPlusNft] = []
    
    init(numberOfNfts: Int, walletAddress: String, nfts: [UPlusNft]) {
        self.numberOfNfts = numberOfNfts
        self.walletAddress = walletAddress
        self.nfts = nfts
    }
}
