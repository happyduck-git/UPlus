//
//  NFTCellReactor.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/01/27.
//

import UIKit

import ReactorKit

final class NFTCellReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var url: URL?
        let name: String?
    }
    
    struct Dependency {
        let nft: NFTProtocol
    }
    
    let initialState: State
    let dependency: Dependency
    
    init(dependency: Dependency) {
        let nft = dependency.nft
        initialState = .init(url: URL(string: nft.imageURLString), name: nft.name)
        self.dependency = dependency
    }
}
