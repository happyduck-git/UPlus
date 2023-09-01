//
//  NFTCell.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/01/27.
//

import UIKit

import ReactorKit
import Nuke

final class NFTCell: UICollectionViewCell, View {
    
    private lazy var imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 4 * scale
        $0.layer.borderWidth = 0.3 * scale
        $0.layer.borderColor = UIColor(hex: 0xCDCDCD).cgColor
        $0.layer.masksToBounds = true
        addSubview($0)
    }
    
    private lazy var nameLabel = UILabel().then {
        $0.textColor = .grey04
        $0.font = .body01
        addSubview($0)
    }
    
    var disposeBag: DisposeBag = .init()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = .init()
    }
    
    func bind(reactor: NFTCellReactor) {
        bindState(reactor)
        bindAction(reactor)
    }
    
    private func setUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        imageView.snp.makeConstraints {
            $0.width.equalTo(imageView.snp.height)
            $0.top.leading.trailing.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(2 * scale)
            $0.top.equalTo(imageView.snp.bottom).offset(10 * scale)
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-2 * scale)
        }
    }
    
    private func bindState(_ reactor: NFTCellReactor) {
        nameLabel.text = reactor.currentState.name
        
        if let url = reactor.currentState.url {
            ImagePipeline.shared.loadImage(with: url) { result in
                self.imageView.image = try? result.get().image
            }
        }
    }
    
    private func bindAction(_ reactor: NFTCellReactor) {
        
    }
}
