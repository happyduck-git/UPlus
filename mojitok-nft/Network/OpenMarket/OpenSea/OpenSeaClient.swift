//
//  OpenSeaClient.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/03.
//

import Foundation

import RxSwift
import Alamofire
import RxAlamofire

public final class OpenSeaClient {
    
    public static let shared = OpenSeaClient()
    
    private let decoder = JSONDecoder()
    private let disposeBag = DisposeBag()
    private let queue = DispatchQueue(label: "net.platfarm.mojitok-nft.OpenSeaClient", qos: .utility)
    
    private init() {}

    func newnft(address: String, slug: String?, completion: @escaping (([OpenSeaNFT]) -> Void)) {
        AF.request(OpenseaRouter.nft(address: address, limit: 50, offset: 0, orderBy: slug))
            .response { [weak self] response in
                guard let data = response.data,
                      let nfts = try? self?.decoder.decode(AssetsResponse.self, from: data).assets else {
                          completion([])
                          return
                      }
                completion(nfts)
            }
    }
    
    func collectionNFTs(address: String, collectionSlug: String, completion: @escaping (([OpenSeaNFT]) -> Void)) {
        AF.request(OpenseaRouter.collectionNFTs(address, collectionSlug))
            .response { [weak self] response in
                if let data = response.data {
                    if (String(data: data, encoding: .utf8) ?? "").contains("throttled") {
                        print("🛰 OpenseaRouter.collectionNFTs Throttle 🔄")
                    }
                }
                guard let data = response.data,
                      let nfts = try? self?.decoder.decode(AssetsResponse.self, from: data).assets else {
                          completion([])
                          return
                      }
                completion(nfts)
            }
    }
    
    func newcollection(slug: String, completion: @escaping ((OpenSeaNFTDetailCollection?) -> Void)) {
        AF.request(OpenseaRouter.collection(slug))
            .response { [weak self] response in
                guard let data = response.data,
                      let collection = try? self?.decoder.decode(OpenSeaNFTCollectionResponse.self, from: data).collection else {
                          completion(nil)
                          return
                      }
                completion(collection)
            }
    }
    
    func collections(owner address: String) -> [OpenSeaCollection] {
        let semaphore = DispatchSemaphore(value: 0)
        var result: [OpenSeaCollection] = []
        
        AF.request(OpenseaRouter.collections(address))
            .response { [weak self] response in
                if let data = response.data {
                    if (String(data: data, encoding: .utf8) ?? "").contains("throttled") {
                        print("🛰 OpenseaRouter.collections Throttle 🔄")
                    }
                }
                guard let data = response.data,
                      let collections = try? self?.decoder.decode([OpenSeaCollection].self, from: data) else {
                    semaphore.signal()
                    return
                }
                result = collections
                semaphore.signal()
            }
        semaphore.wait()
        return result
    }
    
    func image(url: URL, completion: @escaping ((Data?) -> Void)) {
        AF.request(url)
            .response { response in
                if let data = response.data {
                    completion(data)
                } else {
                    completion(nil)
                }
            }
    }
}

struct OpenSeaNFTCollectionResponse: Codable {
    let collection: OpenSeaNFTDetailCollection
}

struct OpenSeaNFTDetailCollection: Codable {
    let stats: OpenSeaNFTCollectionStats
}

struct OpenSeaNFTCollectionStats: Codable {
    let floor_price: Double
}
