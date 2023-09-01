//
//  OpenSeaNFT.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/01/28.
//

import Foundation
                                                                                             
public struct OpenSeaNFT: NFTProtocol, Codable {
    let id: Int
    let owner: OpenSeaNFTOwner?
    let name: String?
    let permalink: String
    let sell_orders: [OpenSeaNFTOrder]?
    let last_sale: OpenSeaNFTLastSale?
    let collection: OpenSearNFTCollection
    let creator: OpenSeaCreator?
    let price: Int?
    let dt = Date.nowString
    let tokenID: String
    let description: String?
    let imageURLString: String
    var collectionName: String {
        get {
            collection.name
        }
    }
    var lastPrice: Double? {
        get {
            if let lastPrice = last_sale?.total_price,
                let doubleLastPrice = Double(lastPrice) {
                let lastPrice = doubleLastPrice / 1000000000
                return lastPrice / 1000000000
            } else {
                return nil
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, price, owner, sell_orders, dt, collection, last_sale, creator, permalink
        case tokenID = "token_id"
        case imageURLString = "image_url"
    }
}

struct OpenSeaCreator: Codable {
    let user: OpenseaUser?
}

struct OpenseaUser: Codable {
    let username: String?
}

struct OpenSeaNFTOwner: Codable {
    let user: OpenSeaNFTUser?
    let profile_img_url: String
    let address: String
    
    struct OpenSeaNFTUser: Codable {
        let username: String?
    }
}

struct OpenSeaNFTOrder: Codable {
    let sale_kind: Int
    let payment_token_contract: OpenSeaNFTPaymentTokenContract
}

struct OpenSearNFTCollection: Codable {
    let name: String
    let image_url: String
    let slug: String
}

struct OpenSeaNFTPaymentTokenContract: Codable {
    let symbol: String
}

struct OpenSeaNFTLastSale: Codable {
    let total_price: String
    let payment_token: OpenSeaPaymentToken?
}

extension OpenSeaNFT {
    var lottieTextDictionary: [String: String] {
        let ownerAddress = WalletRepository.shared.getCurrentWallet()?.address
        var dic: [String: String] = [
            "cn": collection.name,
            "on": (ownerAddress ?? owner?.address ?? "0x"),
            "id": tokenID,
            "cp": "\(Double(price ?? 0) == 0 ? 0.03 : Double(price ?? 0))",
            "fp": "0",
            "dt": Date.nowString,
            "an": creator?.user?.username ?? "Creator name"
        ]
        
        switch sell_orders?.first?.payment_token_contract.symbol ?? "" {
        case "ETH":
            dic["sa"] = "Bid Open!"
        case "WETH":
            dic["sa"] = "Buy Now!"
        default:
            dic["sa"] = "Not Sale!"
        }
        
        if let weiPrice = Double(last_sale?.total_price ?? "0") {
            let ethPrice = Double(weiPrice / 1000000000000000000)
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumSignificantDigits = 4
            if let stringPrice = numberFormatter.string(from: NSNumber(value: ethPrice)) {
                dic["cp"] = stringPrice
            } else {
                let stringPrice = String(format: "%.3f", ethPrice)
                dic["cp"] = stringPrice
            }
        } else {
            dic["cp"] = "Not price"
        }
        return dic
    }
}

struct OpenSeaPaymentToken: Codable {
    let eth_price: String
}

public struct OpenSeaSimpleNFT: NFTProtocol, Codable {
    var id: Int
    var owner: OpenSeaNFTOwner?
    var tokenID: String
    var name: String?
    var description: String?
    var imageURLString: String
    var price: Int?
    var collectionName: String
    var permalink: String
    var lastPrice: Double?
}
