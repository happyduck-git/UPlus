//
//  TemplateUtility.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/16.
//

import UIKit

//import Lottie

final class TemplateUtility {
    
    static let shared = TemplateUtility()
    
    private let queue = DispatchQueue(label: "", qos: .utility)
    private var animationView: AnimationView?
    private var image: UIImage?
    
    private init() {
    }
    
    func setup(_ animationView: AnimationView) {
        queue.sync {
            self.animationView = animationView
        }
    }
     
    func updateTemplate(_ template: Template) {
        queue.sync {
            if let animationView = animationView {
                animationView.animation = .named(template.lottieFileName)
            }
        }
    }
    
    func updateImage(key: String, data: Data) {
        queue.sync {
            if let animationView = animationView {
                let base64 = "data:image/png;base64," + data.base64EncodedString()
                animationView.animation?.assetLibrary?.imageAssets["image_2"]?.directory = base64
                animationView.reloadImages()
            }
        }
    }
    
    func updateText(dic: [String: String]) {
        queue.sync {
            if let animationView = animationView {
                let textProvider = DictionaryTextProvider(dic)
                animationView.textProvider = textProvider
            }
        }
    }
}
