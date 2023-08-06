//
//  WalletViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/04.
//

import Foundation
import Combine

final class WalletViewViewModel {
    
    private let firestoreManager = FirestoreManager.shared
    
    var numberOfNfts: Int = 0
    var walletAddress: String = ""
    @Published var nfts: [UPlusNft] = []
    
    init() {
        self.getNfts()
    }
}

extension WalletViewViewModel {
    func getNfts() {
      
            do {
                let user = try UPlusUser.getCurrentUser()
                guard let nftList = user.userNfts else { return }
                firestoreManager.getOwnedNfts(referenceList: nftList) {
                    print("nfts: \($0)")
                }
                
//                for nft in nfts {
//                    let type = nft.nftDetailType
//                    let lastChar = type.last
//                    let isNumber = lastChar?.isNumber ?? false
//                    print("isnum? \(isNumber)")
//                    if isNumber {
//                        let string = String(lastChar)
//                        let rawVal = String(format: type, String(lastChar!))
//                        print("rawval: \(rawVal)")
//                        print(UPlusNftType(rawValue: rawVal))
//                    }
//                    
//                }
            }
            catch {
                
            }
        
    }
}
