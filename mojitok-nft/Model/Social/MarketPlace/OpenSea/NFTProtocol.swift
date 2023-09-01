//
//  NFTProtocol.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/01/28.
//

protocol NFTProtocol {
    var id: Int { get }
    var owner: OpenSeaNFTOwner? { get }
    var tokenID: String { get }
    var name: String? { get }
    var description: String? { get }
    var imageURLString: String { get }
    var price: Int? { get }
    var collectionName: String { get }
    var permalink: String { get }
    var lastPrice: Double? { get }
}

extension NFTProtocol {
    var simple: OpenSeaSimpleNFT {
        return .init(id: id, owner: owner, tokenID: tokenID, name: name, description: description, imageURLString: imageURLString, price: price, collectionName: collectionName, permalink: permalink, lastPrice: lastPrice)
    }
}
