//
//  IDCardView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/29.
//

import UIKit
import AVFoundation

protocol IDCardViewDelegate: AnyObject {
    func shareOnSlackDidTap()
}

final class IDCardView: UIView {
    
    enum CardType {
        case step1
        case step2
        
        var title: String {
            switch self {
            case .step1:
                return "STEP 1"
            case .step2:
                return "STEP 2"
            }
        }
        
        var subTitle: String {
            switch self {
            case .step1:
                return "ID 카드를 다운받아주세요"
            case .step2:
                return "슬랙으로 이동해 ID카드 영상을 자랑해주세요."
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .step1:
                return "ID 카드 다운로드"
            case .step2:
                return "슬랙에 자랑하러 가기"
            }
        }
        
        var buttonImage: UIImage? {
            switch self {
            case .step1:
                return UIImage(named: ImageAssets.downloadBlack)
            case .step2:
                return UIImage(named: ImageAssets.slackBlack)
            }
        }
    }
    
    weak var delegate: IDCardViewDelegate?
    
    // MARK: - UI Elements
    var player: AVPlayer?

    private let title: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UPlusColor.mint05
        label.font = .systemFont(ofSize: UPlusFont.h1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UPlusColor.blue04
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playerView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAssets.idCardExample)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        button.backgroundColor = UPlusColor.mint01
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonEleStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10.0
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let buttonImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let buttonTitle: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray08
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI()
        self.setLayout()
        self.backgroundColor = .white
        self.configure(cardType: .step1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.button.layer.cornerRadius = self.button.frame.height / 2
        self.playerView.heightAnchor.constraint(equalTo: self.playerView.widthAnchor).isActive = true
    }
}

// MARK: - Configure
extension IDCardView {
    func configure(cardType: CardType) {
        self.title.text = cardType.title
        self.subTitle.text = cardType.subTitle
        self.buttonTitle.text = cardType.buttonTitle
        self.buttonImage.image = cardType.buttonImage
        
        switch cardType {
        case .step1:
            self.button.addTarget(self, action: #selector(downloadContent), for: .touchUpInside)
        case .step2:
            self.button.addTarget(self, action: #selector(shareOnSlack), for: .touchUpInside)
        }
        
        // ID || Ex-NFT 에 따라서 다른 이미지
    }
}

extension IDCardView {
    @objc private func downloadContent() {
        // TODO: Download content
    }
    
    @objc private func shareOnSlack() {
        print("Tapped")
        self.delegate?.shareOnSlackDidTap()
    }
}

// MARK: - Set UI & Layout
extension IDCardView {
    private func setUI() {
        self.addSubviews(self.title,
                         self.subTitle,
                         self.playerView,
                         self.button)
        
        self.button.addSubviews(self.buttonEleStack)
        self.buttonEleStack.addArrangedSubviews(self.buttonImage,
                                                self.buttonTitle)
    }

    private func setLayout() {
        NSLayoutConstraint.activate([
            self.title.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 2),
            self.title.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.title.trailingAnchor, multiplier: 2),
            
            self.subTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.title.bottomAnchor, multiplier: 2),
            self.subTitle.leadingAnchor.constraint(equalToSystemSpacingAfter: self.title.leadingAnchor, multiplier: 1),
            self.title.trailingAnchor.constraint(equalToSystemSpacingAfter: self.subTitle.trailingAnchor, multiplier: 1),
            
            self.playerView.topAnchor.constraint(equalToSystemSpacingBelow: self.subTitle.bottomAnchor, multiplier: 2),
            self.playerView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.subTitle.leadingAnchor, multiplier: 1),
            self.subTitle.trailingAnchor.constraint(equalToSystemSpacingAfter: self.playerView.trailingAnchor, multiplier: 1),
            
            self.button.topAnchor.constraint(equalToSystemSpacingBelow: self.playerView.bottomAnchor, multiplier: 1),
            self.button.heightAnchor.constraint(equalToConstant: LoginConstants.buttonHeight),
            self.button.leadingAnchor.constraint(equalToSystemSpacingAfter: self.playerView.leadingAnchor, multiplier: 1),
            self.playerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.button.trailingAnchor, multiplier: 1),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.button.bottomAnchor, multiplier: 3)
        ])
        
        NSLayoutConstraint.activate([
            self.buttonEleStack.topAnchor.constraint(equalToSystemSpacingBelow: self.button.topAnchor, multiplier: 1),
            self.buttonEleStack.centerXAnchor.constraint(equalTo: self.button.centerXAnchor),
            self.button.bottomAnchor.constraint(equalToSystemSpacingBelow: self.buttonEleStack.bottomAnchor, multiplier: 2)
            
        ])
    }
}

// MARK: - Private
extension IDCardView {
    func playVideo() {
        
        guard let filePath = Bundle.main.path(forResource: "ID CARD_1", ofType: "mp4") else {
                    print("cannot find file path")
                    return
                }
                
                let videoURL = URL(fileURLWithPath: filePath)
                player = AVPlayer(url: videoURL)
                
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = self.playerView.bounds
                self.playerView.layer.addSublayer(playerLayer)
                
                player?.play()
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct IDCardView_PreView: PreviewProvider{
    static var previews: some View {
        UIViewPreview {
            let view = IDCardView(frame: .zero)
            return view
        }.previewLayout(.sizeThatFits)
    }
}
#endif
