//
//  HomeViewReactor.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/01/27.
//

import Foundation

import ReactorKit
import Pure
import RxDataSources

final class HomeViewReactor2: Reactor {
    // MARK: - Declarations
    struct Dependency {
        let templateCreateViewReactorFactory: TemplateCreateViewReactor2.Factory
        let lottieViewReactorFactory: LottieViewReactor.Factory
        
        let walletRepository: WalletRepository
        let nftRepository: NFTRepository
    }
    
    struct Payload {
        
    }
    
    enum Action {
        case reload
        case allSelecte(indexPath: IndexPath)
    }
    
    enum Mutation {
        case fetchAll([NFTProtocol])
        case openTemplateView(nft: NFTProtocol)
        case setIsEmpty
    }
    
    struct State {
        var nftAllSections: [NFTSection]
        var openNFTView: NFTProtocol?
        var isEmpty: Bool = false
    }

    // MARK: - Property
    let initialState: State
    let dependency: Dependency
    var isFetchedAll: Bool = false
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(dependency: Dependency, payload: Payload) {
        initialState = .init(nftAllSections: [])
        
        self.dependency = dependency
    }
    
    // MARK: - Method
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let eventMutation = dependency.nftRepository.event
            .flatMap { [weak self] event -> Observable<Mutation> in
                if event == .all { return self?.mutate(event: event) ?? .empty() }
                else { return .empty() }
            }
        return Observable.of(mutation, eventMutation).merge()
    }
    
    func mutate(event: NFTRepositoryEvent) -> Observable<Mutation> {
        isFetchedAll = true
        return dependency.nftRepository.fetchAllNFTs().map { .fetchAll($0) }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .allSelecte(let indexPath):
            if let nft = currentState.nftAllSections.first?.items[indexPath.item].dependency.nft {
                return .just(.openTemplateView(nft: nft))
            }
            return .empty()
        case .reload:
            if dependency.walletRepository.getCurrentWallet() == nil {
                return .just(.setIsEmpty)
            } else {
                dependency.nftRepository.refresh()
                return .empty()
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .fetchAll(nfts):
            if nfts.isEmpty, isFetchedAll {
                state.isEmpty = true
            } else {
                state.isEmpty = false
            }
                
            isFetchedAll = true
            let totalPrice = nfts.reduce(0.0) { $0 + ($1.lastPrice ?? 0) }
            state.nftAllSections = [.init(model: (), items: nfts.map { .init(dependency: .init(nft: $0)) })]
            state.openNFTView = nil
        case .openTemplateView(let nft):
            state.openNFTView = nft
        case .setIsEmpty:
            state.isEmpty = true
            state.openNFTView = nil
        }
        return state
    }
}
