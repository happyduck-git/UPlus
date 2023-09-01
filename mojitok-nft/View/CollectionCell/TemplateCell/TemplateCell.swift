//
//  TemplateCell.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/08.
//

import UIKit

import ReactorKit

final class TemplateCell: UICollectionViewCell, View {
    
    private lazy var imageView = UIImageView().then {
        $0.layer.cornerRadius = 8 * scale
        $0.layer.masksToBounds = true
        addSubview($0)
    }
    
    private lazy var lockImageView = UIImageView().then {
        $0.tintColor = .white01
        $0.layer.cornerRadius = 8 * scale
        $0.layer.masksToBounds = true
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
    
    func bind(reactor: TemplateCellReactor) {
        bindState(reactor)
        bindAction(reactor)
    }
    
    private func setUI() {
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        lockImageView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bindState(_ reactor: TemplateCellReactor) {
        imageView.image = reactor.currentState.image
        lockImageView.image = reactor.currentState.lockImage
    }
    
    private func bindAction(_ reactor: TemplateCellReactor) {
        
    }
}
