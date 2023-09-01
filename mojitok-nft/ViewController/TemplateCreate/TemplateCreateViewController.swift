//
//  TemplateCreateViewController.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/07.
//

import UIKit
import AVKit

import ReactorKit
import RxDataSources
import Nuke

enum OutputFormat {
    case video
    case image
}

final class TemplateCreateViewController: UIViewController, View {
    // MARK: - UI Component
    private lazy var topBar = TopBar(dependency: reactor!.generateTopbarDependency(), payload: .init(title: "", isIdenticon: false)).then {
        $0.setLeadingItem(mjtImage: .back)
        $0.delegate = self
        view.addSubview($0)
    }
    
    private lazy var saveButton = UIButton().then {
        $0.backgroundColor = .mojitokBlue
        $0.layer.cornerRadius = 5 * scale
        $0.setTitle("Save", for: .normal)
        $0.setTitleColor(.white01, for: .normal)
        $0.titleLabel?.font = .body03
        view.addSubview($0)
    }
    
    private lazy var contentView = AnimationView().then {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 4 * scale
        $0.loopMode = .loop
        $0.contentMode = .scaleAspectFit
        templateUtility.setup($0)
        view.addSubview($0)
    }
    
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<TemplateSection>(configureCell: { _, collectionView, indexPath, reactor in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemplateCell.identifier, for: indexPath) as! TemplateCell
        cell.reactor = reactor
        return cell
    })
    
    private lazy var collectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        let width = (UIScreen.main.bounds.width - 71 * scale) / 4
        $0.itemSize = .init(width: width, height: width)
        $0.minimumLineSpacing = 10 * scale
        $0.minimumInteritemSpacing = 0
        $0.sectionInset = .init(top: 30 * scale, left: 16 * scale, bottom: 30 * scale, right: 16 * scale)
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout).then {
        $0.backgroundColor = .grey02
        $0.register(TemplateCell.self, forCellWithReuseIdentifier: TemplateCell.identifier)
        view.addSubview($0)
    }
    
    private lazy var blockView = UIView().then {
        $0.backgroundColor = .init(hex: 0xEDEDED).withAlphaComponent(0.5)
        view.addSubview($0)
    }
    
    private lazy var indicator = UIActivityIndicatorView().then {
        $0.layer.cornerRadius = 8 * scale
        $0.layer.backgroundColor = UIColor.white01.cgColor
        $0.frame.center = self.view.bounds.center
        $0.frame.size = .init(width: 70 * scale, height: 70 * scale)
        $0.startAnimating()
        view.addSubview($0)
    }
    
    // MARK: - Property
    var disposeBag: DisposeBag = .init()
    var overLayer: AnimationView?
    private let templateUtility = TemplateUtility.shared
    private var imageData: Data?
    private var isLoadedText: Bool = false {
        didSet {
            if isLoadedText,
               isLoadedImage {
                dismissIndicator()
            }
        }
    }
    private var isLoadedImage: Bool = false {
        didSet {
            if isLoadedText,
               isLoadedImage {
                dismissIndicator()
            }
        }
    }
    
    // MARK: - Init
    init(reactor: TemplateCreateViewReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !isLoadedText || !isLoadedImage {
            presentIndicator()
        } else {
            dismissIndicator()
        }
    }
    
    // MARK: - Setup Method
    func bind(reactor: TemplateCreateViewReactor) {
        setUI()
        bindState(reactor)
        bindAction(reactor)
    }
    
    private func setUI() {
        view.backgroundColor = .bg
        
        topBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(64 * scale)
        }
        
        saveButton.snp.makeConstraints {
            $0.width.equalTo(53 * scale)
            $0.height.equalTo(27 * scale)
            $0.top.equalTo(topBar.snp.bottom).offset(4 * scale)
            $0.trailing.equalToSuperview().offset(-16 * scale)
        }
        
        contentView.snp.makeConstraints {
            $0.width.equalTo(contentView.snp.height)
            $0.top.equalTo(saveButton.snp.bottom).offset(7 * scale)
            $0.leading.equalToSuperview().offset(10 * scale)
            $0.trailing.equalToSuperview().offset(-10 * scale)
        }
        
        collectionView.snp.makeConstraints {
            $0.height.equalTo(collectionView.snp.width).multipliedBy(0.29)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        blockView.snp.makeConstraints {
            $0.top.leading.bottom.trailing.equalToSuperview()
        }
        
        indicator.snp.makeConstraints {
            $0.width.height.equalTo(70 * scale)
            $0.center.equalToSuperview()
        }
    }
    
    private func bindState(_ reactor: TemplateCreateViewReactor) {
        reactor.state.map { $0.templateSections }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.selectedTemplate }
            .bind { [weak self] template in
                self?.presentIndicator {
                    DispatchQueue.global().async {
                        self?.setTemplate(template: template, nft: reactor.payload.nft)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.render }
            .bind { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.presentIndicator {
                    self.render(format: self.reactor!.payload.format)
                }
                
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.lottieTextDictionary }
            .bind { [weak self] dic in
                guard let self = self else {
                    return
                }
                if self.isLoadedText == false {
                    self.isLoadedText = true
                }
                if let template = reactor.currentState.selectedTemplate {
                    let keys = self.contentView .getLayerKeypaths()
                    let updatedDic = template.updateDic(keys: keys, dic: dic)
                    self.updateText(updatedDic)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.pushShareVC }
            .bind { [weak self] _ in
                self?.pushShareVC()
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.collectionImageData }
            .bind { [weak self] data in
                if self?.isLoadedImage == false {
                    self?.isLoadedImage = true
                }
                self?.updateImage(key: "image_0", data: data)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindAction(_ reactor: TemplateCreateViewReactor) {
        collectionView.rx.itemSelected
            .map(Reactor.Action.selectTemplate)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .map { _ in Reactor.Action.save }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.just(Reactor.Action.fetchTemplate)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        if let openSeaNFT = reactor.payload.nft as? OpenSeaNFT {
            Observable.just(Reactor.Action.requestCollection(openSeaNFT))
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            Observable.just(Reactor.Action.requestCollectionImage(openSeaNFT))
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Method
    private func presentIndicator(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.indicator.startAnimating()
            self.indicator.isHidden = false
            self.blockView.isHidden = false
            completion?()
        }
    }
    
    private func dismissIndicator(completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            self.blockView.isHidden = true
            completion?()
        }
    }
    
    private func pushShareVC() {
        guard let reactor = reactor else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            let vc = TemplateShareViewController(reactor: reactor.dependency.templateShareViewReactorFactory.create(payload: .init(art: reactor.payload.art!, isLive: true)))
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func setTemplate(template: Template, nft: NFTProtocol) {        
        DispatchQueue.global().async { [weak self] in
            if let reactor = self?.reactor,
               let url = URL(string: reactor.payload.nft.imageURLString) {
                ImagePipeline.shared.loadData(with: url) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let result):
                        self.contentView.animation = .fileURL(template.fileURL)
                        let keypaths = self.contentView.getLayerKeypaths()
                        if let dic = reactor.currentState.lottieTextDictionary,
                           let template = reactor.currentState.selectedTemplate {
                            let updatedDic = template.updateDic(keys: keypaths, dic: dic)
                            if !updatedDic.isEmpty {
                                self.updateText(updatedDic)
                            }
                        }
                        if let data = reactor.currentState.collectionImageData {
                            self.updateImage(key: "image_0", data: data)
                        }
                        self.imageData = result.data
                        self.updateImage(key: "image_1", data: result.data)
                        if self.reactor?.payload.format == .video {
                            self.contentView.play()
                        } else {
                            self.contentView.updateAnimationFrame(self.contentView.animation?.endFrame ?? 0)
                        }
                    case .failure(let error):
                        print("Fail fetch image from Nuke: \(error.localizedDescription)")
                    }
                    self.dismissIndicator()
                }
            }
        }
    }
    
    private func render(format: OutputFormat) {
        switch format {
        case .video:
            renderToVideo()
        case .image:
            renderToImage()
        }
    }
    
    private func updateImage(key: String, data: Data) {
        let base64 = "data:image/png;base64," + data.base64EncodedString()
        if key == "image_1",
           let size = UIImage(data: data)?.size {
            if size.width > size.height {
                let scale = size.height / size.width
                
                contentView = updateHeightSize(scale: scale, animationView: contentView)
                contentView = updateImageHeightSize(scale: scale, animationView: contentView)
            } else {
                let scale = size.width / size.height
                
                contentView = updateWidthSize(scale: scale, animationView: contentView)
                contentView = updateImageWidthSize(scale: scale, animationView: contentView)
            }
        }
        contentView.animation?.assetLibrary?.imageAssets[key]?.name = base64
        contentView.animation?.assetLibrary?.imageAssets[key]?.directory = ""
        
        contentView.animation = contentView.animation
    }
    
    private func updateWidthSize(scale: CGFloat, animationView: AnimationView) -> AnimationView {
        let result = animationView
        
        if let layers = animationView.animation?.layers {
            
            for layerIndex in 0..<layers.count {
                if layers[layerIndex].name.contains("frame"),
                   layers[layerIndex].type == .shape,
                   let shapeLayer = layers[layerIndex] as? ShapeLayerModel {
                    
                    for itemIndex in 0..<shapeLayer.items.count {
                        if shapeLayer.items[itemIndex].type == .group,
                           let group = shapeLayer.items[itemIndex] as? Group {
                            
                            for itemIndex in 0..<group.items.count {
                                if group.items[itemIndex].type == .rectangle,
                                    let rectangleItem = group.items[itemIndex] as? Rectangle {
                                    
                                    let size = rectangleItem.size.keyframes.first!.value
                                    let newSize: KeyframeGroup<Vector3D> = .init(.init(x: size.x * scale, y: size.y, z: size.z))
                                    (group.items[itemIndex] as? Rectangle)?.size = newSize
                                }
                            }
                            shapeLayer.items[itemIndex] = group
                        }
                    }
                    result.animation?.layers[layerIndex] = shapeLayer
                }
            }
        }
        return result
    }
    
    private func updateHeightSize(scale: CGFloat, animationView: AnimationView) -> AnimationView {
        let result = animationView
        
        if let layers = animationView.animation?.layers {
            
            for layerIndex in 0..<layers.count {
                if layers[layerIndex].name.contains("frame"),
                   layers[layerIndex].type == .shape,
                   let shapeLayer = layers[layerIndex] as? ShapeLayerModel {
                    
                    for itemIndex in 0..<shapeLayer.items.count {
                        if shapeLayer.items[itemIndex].type == .group,
                           let group = shapeLayer.items[itemIndex] as? Group {
                            
                            for itemIndex in 0..<group.items.count {
                                if group.items[itemIndex].type == .rectangle,
                                    let rectangleItem = group.items[itemIndex] as? Rectangle {
                                    
                                    let size = rectangleItem.size.keyframes.first!.value
                                    let newSize: KeyframeGroup<Vector3D> = .init(.init(x: size.x, y: size.y * scale, z: size.z))
                                    (group.items[itemIndex] as? Rectangle)?.size = newSize
                                }
                            }
                            shapeLayer.items[itemIndex] = group
                        }
                    }
                    result.animation?.layers[layerIndex] = shapeLayer
                }
            }
        }
        return result
    }
    
    private func updateImageWidthSize(scale: CGFloat, animationView: AnimationView) -> AnimationView {
        let result = animationView
        
        if let layers = animationView.animation?.layers {
            
            for layerIndex in 0..<layers.count {
                if layers[layerIndex].name.contains("resize"),
                   layers[layerIndex].type == .image,
                   let imageLayer = layers[layerIndex] as? ImageLayerModel {
                    for keyframeIndex in 0..<imageLayer.transform.scale.keyframes.count {
                        let size = imageLayer.transform.scale.keyframes[keyframeIndex].value
                        let newSize: Keyframe<Vector3D> = .init(.init(x: size.x * scale, y: size.y, z: size.z))
                        imageLayer.transform.scale.keyframes[keyframeIndex] = newSize
                    }
                    result.animation?.layers[layerIndex] = imageLayer
                }
            }
        }
        return result
    }
    
    private func updateImageHeightSize(scale: CGFloat, animationView: AnimationView) -> AnimationView {
        let result = animationView
        
        if let layers = animationView.animation?.layers {
            
            for layerIndex in 0..<layers.count {
                if layers[layerIndex].name.contains("resize"),
                   layers[layerIndex].type == .image,
                   let imageLayer = layers[layerIndex] as? ImageLayerModel {
                    for keyframeIndex in 0..<imageLayer.transform.scale.keyframes.count {
                        let size = imageLayer.transform.scale.keyframes[keyframeIndex].value
                        let newSize: Keyframe<Vector3D> = .init(.init(x: size.x, y: size.y * scale, z: size.z))
                        imageLayer.transform.scale.keyframes[keyframeIndex] = newSize
                    }
                    result.animation?.layers[layerIndex] = imageLayer
                }
            }
        }
        return result
    }
    
    private func updateText(_ dic: [String: String]) {
        let textProvider = DictionaryTextProvider(dic)
        contentView.textProvider = textProvider
    }
    
    private func getAnimationLayer(frame: CGFloat? = nil) -> CALayer {
        var targetFrame: CGFloat = 0
        if let frame = frame {
            targetFrame = frame
        } else if let frame = contentView.animation?.endFrame {
            targetFrame = frame
        }
        contentView.updateAnimationFrame(targetFrame)
        return contentView.layer
    }
    
    private func renderToImage() {
        DispatchQueue.main.async {
            let layer = self.getAnimationLayer()
            ImageRenderer.shared.quickRenderImage(layer: layer, size: .init(width: 720, height: 720)) { [weak self] data in
                guard let self = self,
                      let reactor = self.reactor else {
                    return
                }
                if let data = data,
                   let template = reactor.selectedTemplate {
                    let art = InventoryService.shared.saveImage(data: data, nft: reactor.payload.nft, template: template)
                    self.reactor!.payload.art = art
                    Observable.just(Reactor.Action.rendered(data))
                        .bind(to: self.reactor!.action)
                        .disposed(by: self.disposeBag)
                }
            }
        }
    }
    
    private func renderToVideo() {
        guard let animation = self.contentView.animation else {
            return
        }
        let frame = animation.endFrame
        let timeScale = animation.framerate
        let group = DispatchGroup()
        var images: [Int: Data] = [:]
        for index in 0..<Int(frame) {
            DispatchQueue.main.async(group: group) {
                self.contentView.updateAnimationFrame(CGFloat(index))
                let layer = self.contentView.layer
                let semaphore = DispatchSemaphore(value: 0)
                ImageRenderer.shared.quickRenderImage(layer: layer, size: .init(width: 720, height: 720)) { data in
                    if let data = data {
                        images[index] = data
                    }
                    semaphore.signal()
                }
                semaphore.wait()
            }
        }
        group.notify(queue: .main) {
            var imageList: [UIImage] = []
            var imageData: Data!
            for index in 0..<Int(frame) {
                let image = UIImage(data: images[index]!)
                imageList.append(image!)

                if index + 1 == Int(frame) {
                    imageData = images[index]
                }
            }
            NewVideoRenderer.shared.quickRenderVideo(images: imageList, endTime: .zero, timeScale: .init(timeScale), type: .multiple) { [weak self] videoData in
                guard let self = self,
                   let videoData = videoData,
                   let reactor = self.reactor else {
                    return
                }
                let disposeBag = self.disposeBag
                if let template = reactor.selectedTemplate {
                    let art = InventoryService.shared.saveVideo(thumbData: imageData, videoData: videoData, nft: reactor.payload.nft, template: template)
                    reactor.payload.art = art
                    Observable.just(Reactor.Action.rendered(videoData))
                        .bind(to: reactor.action)
                        .disposed(by: disposeBag)
                }
            }
        }
    }
}

extension TemplateCreateViewController: TopBarDelegate {
    func didTapLeadingButton() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func didTapTrailingButton() {
    }
}
