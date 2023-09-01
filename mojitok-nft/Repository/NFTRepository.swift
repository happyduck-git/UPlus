//
//  NFTRepository.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/03.
//

import Foundation

import RxSwift
import RxRelay

final class NFTRepository {
    
    static let shared: NFTRepository = .init()
    
    private let walletRepository = WalletRepository.shared
    
    private let disposeBag: DisposeBag = .init()
    private let queue = DispatchQueue(label: "net.platfarm.mojitok-nft.NFTRepository", qos: .utility)
    private let services: [MarketPlaceKind: MarketPlaceServiceProtocol] = [.openSea: OpenSeaService.shared]
    private let allNFTsRelay = BehaviorRelay<[NFTProtocol]?>(value: nil)
    private let dateNFTsRelay = BehaviorRelay<[NFTProtocol]?>(value: nil)
    private let countNFTsRelay = BehaviorRelay<[NFTProtocol]?>(value: nil)
    private let priceNFTsRelay = BehaviorRelay<[NFTProtocol]?>(value: nil)
    
    var isLoaded: Bool = false
    let event = PublishSubject<NFTRepositoryEvent>()
    
//    refresh 와 Add 분리
    private init() {
        if let currentWallet = walletRepository.getCurrentWallet() {
            configuration(addresses: [currentWallet.address])
        } else {
            configuration(addresses: [])
        }
        
        for service in services.values {
            service.event
                .bind { event in
                    switch event {
                    case .all:
                        self.event.onNext(.all)
                    case .date:
                        self.event.onNext(.date)
                    case .collection:
                        self.event.onNext(.collection)
                    case .price:
                        self.event.onNext(.price)
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    func configuration(addresses: [String]) {
        for (_, service) in services {
//            service.configuration(addresses: addresses)
            if let wallet = walletRepository.getCurrentWallet() {
               service.configuration(addresses: [wallet.address])
            }
        }
    }
    
    func refresh() {
        for (_, service) in services {
            service.refresh()
        }
    }
    
    func fetchAllNFTs() -> Observable<[NFTProtocol]> {
        var result: [NFTProtocol] = []
        for (_, service) in services {
            for id in service.allNFTs.keys {
                if let nfts = service.allNFTs[id] {
                    result.append(contentsOf: nfts)
                }
            }
        }
        return .just(result)
    }
    
    func fetchDateNFTs() -> Observable<[NFTProtocol]> {
        var result: [NFTProtocol] = []
        for (_, service) in services {
            for id in service.dateNFTs.keys {
                if let nfts = service.dateNFTs[id] {
                    result.append(contentsOf: nfts)
                }
            }
        }
        return .just(result)
    }
    
    func fetchCollections() -> Observable<[OpenSeaCollection]> {
        var result: [OpenSeaCollection] = []
        for (_, service) in services {
            for id in service.collections.keys {
                if let collection = service.collections[id] {
                    result.append(contentsOf: collection)
                }
            }
        }
        return .just(result)
    }
    
    func fetchPriceNFTs() -> Observable<[NFTProtocol]> {
        var result: [NFTProtocol] = []
        for (_, service) in services {
            for id in service.priceNFTs.keys {
                if let nfts = service.priceNFTs[id] {
                    result.append(contentsOf: nfts)
                }
            }
        }
        return .just(result)
    }
    
    func add(kind: MarketPlaceKind, address: String) {
//        if let service = services[kind] {
//            service.add(address: address)
//        }
        if let wallet = walletRepository.getCurrentWallet(),
           let service = services[kind] {
            service.configuration(addresses: [wallet.address])
        }
    }
    
    func delete(kind: MarketPlaceKind, address: String) {
//        if let service = services[kind] {
//            service.delete(address: address)
//        }
        if let wallet = walletRepository.getCurrentWallet(),
           let service = services[kind] {
            service.configuration(addresses: [wallet.address])
        }
    }
}

/*
func saveTasks(_ tasks: [Task]) -> Observable<Void> {
  let dicts = tasks.map { $0.asDictionary() }
  self.provider.userDefaultsService.set(value: dicts, forKey: .tasks)
  return .just(Void())
}

case .refresh:
  return self.provider.taskService.fetchTasks()
    .map { tasks in
      let sectionItems = tasks.map(TaskCellReactor.init)
      let section = TaskListSection(model: Void(), items: sectionItems)
      return .setSections([section])
    }
*/
