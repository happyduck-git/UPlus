//
//  WalletRepository.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/01/28.
//

import Foundation

import RxSwift
import RxRelay

final class WalletRepository {
    
    static let shared: WalletRepository = .init()
    
    private let currentWalletKey = "WalletRepository.CurrentKey"
    
    private init() {}
    
    func getCurrentWallet() -> WalletProtocol? {
        return ArchiveWallet(
            address: "0x23BE5FbA1BA9c07Ee676250040DB99474Da72997"
        )
        
        if let data = UserDefaults.standard.data(forKey: currentWalletKey),
           let wallet = try? JSONDecoder().decode(ArchiveWallet.self, from: data) {
            return wallet
        }
        return nil
    }
}
