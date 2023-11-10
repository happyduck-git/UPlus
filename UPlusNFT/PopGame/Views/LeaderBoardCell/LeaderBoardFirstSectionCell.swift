//
//  LeaderBoardFirstSectionCell.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/06.
//

import UIKit
import Nuke

final class LeaderBoardFirstSectionCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor(ciColor: .white).cgColor
        imageView.layer.borderWidth = 1.0
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nftInfoStackView: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.bottomLabelFont = .systemFont(ofSize: UPlusFont.caption1)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nftNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: UPlusFont.h5)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let popScoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.caption1)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        setLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        nftImageView.layer.cornerRadius = nftImageView.frame.size.width / 2
    }
    
    // MARK: - Private
    private func setUI() {
        self.backgroundColor = .systemBlue.withAlphaComponent(0.5)
        
        contentView.addSubview(nftImageView)
        contentView.addSubview(nftNameLabel)
        contentView.addSubview(nftInfoStackView)
        contentView.addSubview(popScoreLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            
            self.nftImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.nftImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 3),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.bottomAnchor, multiplier: 1),
            self.nftImageView.widthAnchor.constraint(equalTo: self.nftImageView.heightAnchor),
            
            self.nftInfoStackView.topAnchor.constraint(equalTo: self.nftImageView.topAnchor),
            self.nftInfoStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.nftImageView.trailingAnchor, multiplier: 1),
            self.nftInfoStackView.bottomAnchor.constraint(equalTo: self.nftImageView.bottomAnchor),
            
            self.popScoreLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            self.popScoreLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.nftInfoStackView.trailingAnchor, multiplier: 1),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.popScoreLabel.trailingAnchor, multiplier: 3)
                                                       
        ])
        self.popScoreLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    internal func resetCell() {
//        self.nftImageView.image = nil
        self.nftNameLabel.text = nil
        self.popScoreLabel.text = nil
        self.contentView.backgroundColor = nil
    }
    
    // MARK: - Public
    public func configure(with vm: LeaderBoardFirstSectionCellViewModel) {
    
        self.imageStringToImage(with: vm.nftImage) { result in
            switch result {
            case .success(let image):
                self.nftImageView.image = image
            case .failure(_):
                self.nftImageView.image = UIImage(named: ImageAssets.profileDefault)
            }
        }

        self.nftInfoStackView.topLabelText = "스타트업 마스터 NFT"
        self.nftInfoStackView.bottomLabelText = "Action Count: \(vm.totalActionCount)"
        self.popScoreLabel.text = "\(vm.totalPopScore)"
        
    }
    
    private func imageStringToImage(with urlString: String, completion: @escaping (Result<UIImage?, Error>) -> ()) {
        guard let url = URL(string: urlString) else {
            completion(.failure(ImageError.nukeImageLoadingError))
            return
        }

        ImagePipeline.shared.loadImage(with: url) { result in
            switch result {
            case .success(let success):
                completion(.success(success.image))
                
            case .failure(_):
                completion(.success(UIImage(named: ImageAssets.profileDefault)))
            
            }
        }
    }
    
    enum ImageError: Error {
        case nukeImageLoadingError
    }
}
