//
//  TemplateCreateViewReactor.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/07.
//

import UIKit

import ReactorKit
import RxDataSources
import StoreKit
import FirebaseAnalytics
import Pure

final class TemplateCreateViewReactor2: Reactor, FactoryModule {
    // MARK: - Declarations
    struct Dependency {
        let templateShareViewReactorFactory: TemplateShareViewReactor2.Factory
        let templateRepository: TemplateRepository
    }
    
    struct Payload {
        let nft: NFTProtocol
        let format: OutputFormat
        var art: ArtUIProtocol?
    }
    
    enum Action {
        case fetchTemplate
        case selectTemplate(IndexPath)
        case requestCollection(OpenSeaNFT)
        case requestCollectionImage(OpenSeaNFT)
        case save
        case rendered(Data)
    }
    
    enum Mutation {
        case fetch([TemplateSection])
        case selectedTemplate(Template?)
        case updateText(Double?, OpenSeaNFT)
        case updateImage(Data?)
        case render
        case pushShareVC(Data)
        case fetchDescription(String)
    }
    
    struct State {
        var templateSections: [TemplateSection]
        var selectedTemplate: Template?
        var lottieTextDictionary: [String: String]?
        var collectionImageData: Data?
        var pushShareVC: Void?
        var render: Void?
    }
    
    // MARK: - Property
    let initialState: State
    var dependency: Dependency
    var payload: Payload
    let event = PublishSubject<TemplateCreateEvent>()
    var prevSelectedTemplate: Template?
    
    // MARK: - Init
    init(dependency: Dependency, payload: Payload) {
        self.dependency = dependency
        self.payload = payload
        prevSelectedTemplate = nil
        initialState = .init(templateSections: [.init(model: (), items: [])])
    }
    
    // MARK: - Method
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let eventMutation = event
            .flatMap { [weak self] event -> Observable<Mutation> in
                return self?.mutate(event: event) ?? .empty()
            }
        return Observable.of(mutation, eventMutation).merge()
    }
    
    func mutate(event: TemplateCreateEvent) -> Observable<Mutation> {
        switch event {
        case .collectionPrice(let price):
            if let nft = payload.nft as? OpenSeaNFT {
                return .just(.updateText(price, nft))
            }
            return .empty()
        case .collectionImage(let data):
            return .just(.updateImage(data))
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        print("appVersion: \(getAppVersion())")
        
        switch action {
        case .fetchTemplate:
            switch payload.format {
            case .video:
                let appVersion = getAppVersion()
                return dependency.templateRepository.videoTemplates
                    .map { $0.filter { $0.appVersion <= appVersion } }
                    .compactMap { [weak self] in self?.sortTemplateForCollection(templates: $0) }
                    .map { $0.map { TemplateCellReactor(dependency: .init(template: $0)) } }
                    .map { [TemplateSection(model: (), items: $0)] }
                    .map { Mutation.fetch($0) }
            case .image:
                let appVersion = getAppVersion()
                return dependency.templateRepository.imageTemplates
                    .map { $0.filter { $0.appVersion <= appVersion } }
                    .compactMap { [weak self] in self?.sortTemplateForCollection(templates: $0) }
                    .map { $0.map { TemplateCellReactor(dependency: .init(template: $0))} }
                    .map { [TemplateSection(model: (), items: $0)] }
                    .map { Mutation.fetch($0) }
            }
        case .selectTemplate(let indexPath):
            let template = currentState.templateSections.first?.items[indexPath.item].dependency.template
            let templateName = template?.name ?? "nil"
            Analytics.logEvent("template_select", parameters: ["name": templateName])
            return Observable.of(Observable.just(.selectedTemplate(template)), Observable.just(.fetchDescription(template?.description ?? "Empty"))).merge()
        case .requestCollection(let nft):
            OpenSeaClient.shared.newcollection(slug: nft.collection.slug) { [weak self] collection in
                self?.event.onNext(.collectionPrice(collection?.stats.floor_price))
            }
            return .empty()
        case .requestCollectionImage(let nft):
            if let url = URL(string: nft.collection.image_url) {
                OpenSeaClient.shared.image(url: url) { [weak self] data in
                    self?.event.onNext(.collectionImage(data))
                }
            }
            return .empty()
        case .save:
            return .just(.render)
        case .rendered(let data):
            return .just(.pushShareVC(data))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .fetch(let sections):
            state.selectedTemplate = sections.first?.items.first?.dependency.template
            prevSelectedTemplate = state.selectedTemplate
            state.render = nil
            state.pushShareVC = nil
            let newSections = [TemplateSection(model: (), items: sections.first!.items.map { $0 })]
            state.templateSections = newSections
        case let .updateText(floorPrice, nft):
            var dic = nft.lottieTextDictionary
            if let floorPrice = floorPrice {
                dic["fp"] = String(format: "%.3f", floorPrice)
            }
            state.render = nil
            state.pushShareVC = nil
            state.lottieTextDictionary = dic
        case let .selectedTemplate(template):
            prevSelectedTemplate = template
            state.render = nil
            state.pushShareVC = nil
            state.selectedTemplate = template
        case let .updateImage(data):
            state.render = nil
            state.pushShareVC = nil
            state.collectionImageData = data
        case .render:
            state.selectedTemplate = nil
            state.pushShareVC = nil
            state.render = ()
        case .pushShareVC:
            state.render = nil
            state.pushShareVC = ()
        case .fetchDescription(let description):
            state.render = nil
            state.pushShareVC = nil
        }
        return state
    }
    
    private func getAppVersion() -> Int {
        guard let dictionary = Bundle.main.infoDictionary,
           let version = dictionary["CFBundleShortVersionString"] as? String else {
            return 1
        }
        let versions = version.split(separator: ".")
        if versions.count == 3,
           let majorVersion = Int(versions[0]),
           let middleVersion = Int(versions[1]),
           let minorVersion = Int(versions[2]) {
            return majorVersion * 100 + middleVersion * 10 + minorVersion
        }
        return 1
    }
    
    private func sortTemplateForCollection(templates: [Template]) -> [Template] {
        var collectionTemplates: [Template] = []
        var normalTemplates: [Template] = []
        var purchaseTemplates: [Template] = []
        var mockTemplates: [Template] = []
        for template in templates {
            if template.collectionName == payload.nft.collectionName {
                collectionTemplates.append(template)
            } else if template.isPurchase {
                purchaseTemplates.append(template)
            } else if template.isMock {
                mockTemplates.append(template)
            } else {
                normalTemplates.append(template)
            }
        }
        return collectionTemplates + normalTemplates + purchaseTemplates + mockTemplates
    }
    
    func generateTopbarDependency() -> TopBar.Dependency {
        return .init()
    }
}
