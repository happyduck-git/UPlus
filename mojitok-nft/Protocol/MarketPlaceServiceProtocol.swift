//
//  MarketPlaceServiceProtocol.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/04.
//

import Foundation

import RxSwift
import RxRelay

protocol MarketPlaceServiceProtocol {
    var addresses: [String] { get }
    var allNFTs: [String: [NFTProtocol]] { get }
    var dateNFTs: [String: [NFTProtocol]] { get }
    var collections: [String: [OpenSeaCollection]] { get }
    var priceNFTs: [String: [NFTProtocol]] { get }
    
    var event: PublishSubject<MarketPlaceEvent> { get }
    
    func refresh()
    func configuration(addresses: [String])
    func add(address: String)
    func delete(address: String)
}
