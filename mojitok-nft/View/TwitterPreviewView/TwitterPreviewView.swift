//
//  TwitterPreviewView.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/07/01.
//

import UIKit
import AVFoundation

import RxSwift

protocol TwitterPreviewViewDelegate: AnyObject {
    func closeButton()
    func tweetButton()
}

final class TwitterPreviewView: UIView {
    
    weak var delegate: TwitterPreviewViewDelegate?
    
    private lazy var topBar = UIView().then {
        addSubview($0)
    }
    
    private lazy var closeButton = UIButton().then {
        $0.setImage(.x, tintColor: .twitter)
        topBar.addSubview($0)
    }
    
    private lazy var tweetButton = UIButton().then {
        $0.setTitle("Tweet", for: .normal)
        $0.setTitleColor(.white01, for: .normal)
        $0.backgroundColor = .twitter
        $0.layer.cornerRadius = 14 * scale
        $0.titleLabel?.font = .body04_d
        topBar.addSubview($0)
    }
    
    private lazy var textLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .body04_d
        $0.numberOfLines = 0
        $0.textAlignment = .left
        addSubview($0)
    }
    
    private lazy var imageView = UIImageView().then {
        addSubview($0)
    }
    
    private lazy var avPlayerLayer = AVPlayerLayer().then {
        imageView.layer.addSublayer($0)
    }
    
    private var avPlayerLooper: AVPlayerLooper?
    private let disposeBag = DisposeBag()
    
    init(twitterTweet form: TwitterTweetForm) {
        super.init(frame: .zero)
        
        setUI()
        setAction()
        setContent(twitterTweet: form)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avPlayerLayer.frame = imageView.bounds
    }
    
    private func setUI() {
        self.backgroundColor = .white01
        self.layer.cornerRadius = 4 * scale
        
        topBar.snp.makeConstraints {
            $0.height.equalTo(44 * scale)
            $0.leading.top.trailing.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.width.height.equalTo(40 * scale)
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        tweetButton.snp.makeConstraints {
            $0.width.equalTo(60 * scale)
            $0.height.equalTo(28 * scale)
            $0.trailing.equalToSuperview().offset(-4 * scale)
            $0.centerY.equalToSuperview()
        }
        
        textLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12 * scale)
            $0.top.equalTo(topBar.snp.bottom).offset(12 * scale)
            $0.trailing.equalToSuperview().offset(-12 * scale)
        }
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(220 * scale)
            $0.top.equalTo(textLabel.snp.bottom).offset(8 * scale)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12 * scale)
        }
    }
    
    private func setAction() {
        closeButton.rx.tap
            .bind { [weak self] in
                self?.delegate?.closeButton()
            }
            .disposed(by: disposeBag)
        
        tweetButton.rx.tap
            .bind { [weak self] in
                self?.delegate?.tweetButton()
            }
            .disposed(by: disposeBag)
    }
    
    private func setContent(twitterTweet form: TwitterTweetForm) {
        textLabel.text = form.text
        switch form.art.mediaType {
        case .image:
            imageView.image = form.art.thumbnailImage
        case .video:
            let path = InventoryService.videoCacheFolderURL.appendingPathComponent(form.art.fileName)
            let playerItem = AVPlayerItem(url: path)
            let queuePlayer = AVQueuePlayer(playerItem: playerItem)
            avPlayerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
            queuePlayer.play()
            
            avPlayerLayer.player = queuePlayer
        }
    }
}
