//
//  TemplateRepository.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/15.
//

import Foundation

import RxSwift
import RxRelay

final class TemplateRepository {
    
    static let shared: TemplateRepository = .init()
    
    private let disposeBag: DisposeBag = .init()
    private let queue = DispatchQueue(label: "net.platfarm.mojitok-nft.NFTRepository", qos: .utility)
    private let videoTemplatesRelay = BehaviorRelay<[Template]>(value: [])
    private let imageTemplatesRelay = BehaviorRelay<[Template]>(value: [])
//    private let videoTemplatesRelay = BehaviorRelay<[VideoTemplate]>(value: [
//        .init(name: "0215a", lottieFileName: "template", thumbnailImageString: "thumbnail_basic"),
//        .init(name: "0215a", lottieFileName: "", thumbnailImageString: "thumbnail_giwaway"),
//        .init(name: "0215a", lottieFileName: "", thumbnailImageString: "thumbnail_justpurchased"),
//        .init(name: "0215a", lottieFileName: "", thumbnailImageString: "thumbnail_milestone"),
//        .init(name: "0215a", lottieFileName: "", thumbnailImageString: "thumbnail_respect"),
//        .init(name: "0215a", lottieFileName: "", thumbnailImageString: "thumbnail_welcome")
//    ])
//    private let imageTemplatesRelay = BehaviorRelay<[ImageTemplate]>(value: [
//        .init(name: "0215a", lottieFileName: "template", thumbnailImageString: "thumbnail_basic"),
//        .init(name: "0215a", lottieFileName: "", thumbnailImageString: "thumbnail_giwaway"),
//        .init(name: "0215a", lottieFileName: "", thumbnailImageString: "thumbnail_justpurchased"),
//        .init(name: "0215a", lottieFileName: "", thumbnailImageString: "thumbnail_milestone"),
//        .init(name: "0215a", lottieFileName: "", thumbnailImageString: "thumbnail_respect"),
//        .init(name: "0215a", lottieFileName: "", thumbnailImageString: "thumbnail_welcome")
//    ])
    
    let videoTemplates: Observable<[Template]>
    let imageTemplates: Observable<[Template]>
    
    private init() {
        videoTemplates = videoTemplatesRelay
            .asObservable()
            .subscribe(on: SerialDispatchQueueScheduler(queue: queue, internalSerialQueueName: UUID().uuidString))
        
        imageTemplates = imageTemplatesRelay
            .asObservable()
            .subscribe(on: SerialDispatchQueueScheduler(queue: queue, internalSerialQueueName: UUID().uuidString))
        
        videoTemplatesRelay.accept(TemplateService.shared.templates)
        imageTemplatesRelay.accept(TemplateService.shared.templates)
        
        TemplateService.shared.event
            .bind { [weak self] event in
                switch event {
                case .refresh(let templates):
                    self?.videoTemplatesRelay.accept(templates)
                    self?.imageTemplatesRelay.accept(templates)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func getImageTemplate(index: Int) -> Template? {
        queue.sync {
            if imageTemplatesRelay.value.count > index {
                return imageTemplatesRelay.value[index]
            }
            return nil
        }
    }
    
    func addTemplate(name: String, data: Data) {
        
    }
//    func remove
}
 
