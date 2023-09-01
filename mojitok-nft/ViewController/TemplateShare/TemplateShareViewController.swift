//
//  TemplateShareViewController.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/07.
//

import UIKit

import ReactorKit
import Social
import AVFoundation

final class TemplateShareViewController: UIViewController, View {
    
    // MARK: - UI Component
    private lazy var topBar = TopBar(dependency: reactor!.generateTopbarDependency(), payload: .init(title: "Share", isIdenticon: false)).then {
        $0.setTrailingItem(mjtImage: .x)
        $0.delegate = self
        view.addSubview($0)
    }
    
    private lazy var contentView = UIView().then {
        $0.layer.cornerRadius = 4 * scale
        view.addSubview($0)
    }
    
    private lazy var exportButtonView = ExportButtonView().then {
        $0.delegate = self
        view.addSubview($0)
    }
    
    private lazy var indicatorView = IndicatorView().then {
        $0.isHidden = true
        view.addSubview($0)
    }
    
    private lazy var messageView = MessageImageView().then {
        $0.alpha = 0
        view.addSubview($0)
    }
    
    // MARK: - Property
    private var playerLayer: CALayer?
    private var playerLooper: AVPlayerLooper?
    var disposeBag: DisposeBag = .init()
    
    // MARK: - Init
    init(reactor: TemplateShareViewReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer?.frame = contentView.bounds
    }
    
    // MARK: - Setup Method
    func bind(reactor: TemplateShareViewReactor) {
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
        
        contentView.snp.makeConstraints {
            $0.width.equalTo(contentView.snp.height)
            $0.top.equalTo(topBar.snp.bottom).offset(4 * scale)
            $0.leading.equalToSuperview().offset(10 * scale)
            $0.trailing.equalToSuperview().offset(-10 * scale)
        }
        
        exportButtonView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.bottom).offset(37 * scale)
            $0.leading.equalToSuperview().offset(16 * scale)
            $0.trailing.equalToSuperview().offset(-16 * scale)
            $0.bottom.equalToSuperview().offset(-16 * scale)
        }
        
        indicatorView.snp.makeConstraints {
            $0.top.leading.bottom.trailing.equalToSuperview()
        }
        
        messageView.snp.makeConstraints {
            $0.height.equalTo(30 * scale)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(90 * scale)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func bindState(_ reactor: TemplateShareViewReactor) {
        if !reactor.payload.isLive {
            topBar.setLeadingItem(mjtImage: .back)
        }
        reactor.state.compactMap { $0.image }
            .bind { [weak self] image in
                DispatchQueue.main.async {
                    let imageView = UIImageView(image: image)
                    self?.contentView.addSubview(imageView)
                    imageView.snp.makeConstraints {
                        $0.top.leading.bottom.trailing.equalToSuperview()
                    }
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.videoPath }
            .bind { [weak self] path in
                DispatchQueue.main.async {
                    let playerItem = AVPlayerItem(url: path)
                    let queuePlayer = AVQueuePlayer(playerItem: playerItem)
                    self?.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
                    
                    let playerLayer = AVPlayerLayer(player: queuePlayer)
                    self?.playerLayer = playerLayer
                    playerLayer.frame = self?.contentView.bounds ?? .init(x: 0, y: 0, width: 0, height: 0)
                    self?.contentView.layer.addSublayer(playerLayer)
                    queuePlayer.play()
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.messageViewText }
            .bind { [weak self] text in
                guard let self = self else {
                    return
                }
                self.presentMessageView(text: text)
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.twitterTweetForm }
            .bind { [weak self] form in
                self?.presentTwitterTweetPreviewView(twitterTweet: form)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindAction(_ reactor: TemplateShareViewReactor) {
        Observable.just(Reactor.Action.fetch)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func presentMessageView(text: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.messageView.title = text
            self.indicatorView.isHidden = true
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                guard let self = self else {
                    return
                }
                self.messageView.alpha = 1
            }) { result in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    UIView.animate(withDuration: 0.5) { [weak self] in
                        guard let self = self else {
                            return
                        }
                        self.messageView.alpha = 0
                    }
                }
            }
        }
    }
    
    private func presentTwitterTweetPreviewView(twitterTweet form: TwitterTweetForm) {
        DispatchQueue.main.async { [weak self] in
            let twitterPreviewView = TwitterPreviewView(twitterTweet: form)
            twitterPreviewView.delegate = self
            self?.view.addSubview(twitterPreviewView)
            twitterPreviewView.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.equalTo(244 * scale)
            }
        }
    }
    
    private func dismissTwitterTweetPreviewView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.indicatorView.isHidden = true
            for subView in self.view.subviews {
                if let previewView = subView as? TwitterPreviewView {
                    previewView.removeFromSuperview()
                }
            }
        }
    }
}

extension TemplateShareViewController: TopBarDelegate {
    func didTapLeadingButton() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func didTapTrailingButton() {
        if let art = reactor?.payload.art,
           (reactor?.payload.isLive ?? false),
           reactor?.currentState.isArtSave == false {
            InventoryService.shared.remove(art: art)
        }
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
}

extension TemplateShareViewController: ExportButtonViewDelegate {
    func selectedButton(type: ShareType) {
        guard let reactor = reactor else {
            return
        }
        switch type {
        case .export:
            var items: [Any] = []
            if reactor.payload.art.mediaType == .video {
                if let path = reactor.currentState.videoPath {
                    items = [path]
                }
            } else {
                if let image = reactor.currentState.image {
                    items = [image]
                }
            }
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityVC.completionWithItemsHandler = { [weak self] (activityType, completion, returnedItems, error) in
                guard let self = self else {
                    return
                }
                if completion,
                    let activityType = activityType {
                    switch activityType {
                    case .saveToCameraRoll:
                        self.presentMessageView(text: "Saved to CameraRoll")
                    case .copyToPasteboard:
                        self.presentMessageView(text: "Copied to Pasteboard")
                    default:
                        self.presentMessageView(text: "\(activityType.rawValue.split(separator: ".").last ?? "Empty") - successfully!")
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.indicatorView.isHidden = true
                    }
                }
            }
            DispatchQueue.main.async { [weak self] in
                self?.indicatorView.isHidden = false
                self?.present(activityVC, animated: true)
            }
        case .gallery:
            DispatchQueue.main.async { [weak self] in
                self?.indicatorView.isHidden = false
            }
            Observable.just(Reactor.Action.saveGallery)
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        case .twitter:
            DispatchQueue.main.async { [weak self] in
                self?.indicatorView.isHidden = false
            }
            Observable.just(Reactor.Action.presentTwitterPreview)
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
    }
}

extension TemplateShareViewController: TwitterPreviewViewDelegate {
    func closeButton() {
        dismissTwitterTweetPreviewView()
    }
    
    func tweetButton() {
        dismissTwitterTweetPreviewView()
        DispatchQueue.main.async { [weak self] in
            self?.indicatorView.isHidden = false
        }
        guard let reactor = reactor else {
            return
        }
        Observable.just(Reactor.Action.shareTwitter)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
