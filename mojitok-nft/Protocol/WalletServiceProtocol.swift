//
//  WalletServiceProtocol.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/04.
//

import Foundation

import RxSwift

protocol WalletServiceProtocol {
    var wallets: [WalletProtocol] { get }
    
    func fetch()
    func add(_ address: String)
    func delete(_ address: String)
    func save()
}
