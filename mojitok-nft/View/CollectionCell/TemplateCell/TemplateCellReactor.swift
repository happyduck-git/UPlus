//
//  TemplateCellReactor.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/08.
//

import UIKit

import ReactorKit

final class TemplateCellReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        let image: UIImage?
        var lockImage: UIImage?
    }
    
    struct Dependency {
        let template: Template
    }
    
    let initialState: State
    let dependency: Dependency
    
    init(dependency: Dependency) {
        self.dependency = dependency
        var image: UIImage?
        if let data = try? Data(contentsOf: dependency.template.thumbnailURL) {
            image = .init(data: data)
        }
        var lockImage: UIImage?
        initialState = .init(image: image, lockImage: lockImage)
    }
    
    init(image: UIImage?) {
        self.dependency = .init(template: .init(name: "", version: 0, appVersion: 0, lottieFileName: "", thumbnailImageName: "", isRelease: false, collectionName: nil, isMock: false, isPurchase: false, description: "", twitterForm: nil))
        initialState = .init(image: image)
    }
}
