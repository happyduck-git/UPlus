//
//  ExportButtonView.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/15.
//

import UIKit

import RxSwift

enum ShareType {
    case export
    case gallery
    case twitter
}

protocol ExportButtonViewDelegate: AnyObject {
    func selectedButton(type: ShareType)
}

final class ExportButtonView: UIView {
    
    private lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        addSubview($0)
    }
    
    private lazy var stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8 * scale
        scrollView.addSubview($0)
    }
    
    private lazy var exportButton = UIButton().then {
        $0.setTitle("File to Export", for: .normal)
        $0.setImage(.upload)
        $0.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 9 * scale)
        $0.titleEdgeInsets = .init(top: 0, left: 9 * scale, bottom: 0, right: 0)
        $0.layer.cornerRadius = 4 * scale
        $0.backgroundColor = .mojitokBlue
        $0.titleLabel?.font = .body02
        stackView.addArrangedSubview($0)
    }
    
    private lazy var saveButton = UIButton().then {
        $0.setTitle("Save to Gallery", for: .normal)
        $0.setImage(.save)
        $0.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 9 * scale)
        $0.titleEdgeInsets = .init(top: 0, left: 9 * scale, bottom: 0, right: 0)
        $0.layer.cornerRadius = 4 * scale
        $0.backgroundColor = .mojitokBlue
        $0.titleLabel?.font = .body02
        stackView.addArrangedSubview($0)
    }
    
    private lazy var twitterButton = UIButton().then {
        $0.setTitle("Share it to Twitter", for: .normal)
        $0.setImage(.twitter)
        $0.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 9 * scale)
        $0.titleEdgeInsets = .init(top: 0, left: 9 * scale, bottom: 0, right: 0)
        $0.layer.cornerRadius = 4 * scale
        $0.backgroundColor = .init(hex: 0x1D9BF0)
        $0.titleLabel?.font = .body02
        stackView.addArrangedSubview($0)
    }
    
    private lazy var whatsAppButton = UIButton().then {
        $0.setTitle("Share it to WahtsApp", for: .normal)
        $0.setImage(.whatsApp)
        $0.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 9 * scale)
        $0.titleEdgeInsets = .init(top: 0, left: 9 * scale, bottom: 0, right: 0)
        $0.layer.cornerRadius = 4 * scale
        $0.backgroundColor = .init(hex: 0x25D366)
        $0.titleLabel?.font = .body02
        stackView.addArrangedSubview($0)
    }
    
    private lazy var facebookButton = UIButton().then {
        $0.setTitle("Share it to Facebook", for: .normal)
        $0.setImage(.facebook)
        $0.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 9 * scale)
        $0.titleEdgeInsets = .init(top: 0, left: 9 * scale, bottom: 0, right: 0)
        $0.layer.cornerRadius = 4 * scale
        $0.backgroundColor = .init(hex: 0x4267B2)
        $0.titleLabel?.font = .body02
        stackView.addArrangedSubview($0)
    }
    
    private lazy var instagramButton = UIButton().then {
        $0.setTitle("Share it to Instagram", for: .normal)
        $0.setImage(.instagram)
        $0.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 9 * scale)
        $0.titleEdgeInsets = .init(top: 0, left: 9 * scale, bottom: 0, right: 0)
        $0.layer.cornerRadius = 4 * scale
        $0.backgroundColor = .init(hex: 0xAE108A)
        $0.titleLabel?.font = .body02
        stackView.addArrangedSubview($0)
    }
    
    private let disposeBag = DisposeBag()
    weak var delegate: ExportButtonViewDelegate?
    
    init() {
        super.init(frame: .zero)
        
        setUI()
        bindAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        scrollView.snp.makeConstraints {
            $0.top.leading.bottom.trailing.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.width.equalTo(scrollView.snp.width)
            $0.top.leading.bottom.trailing.equalToSuperview()
        }
        
        exportButton.snp.makeConstraints {
            $0.height.equalTo(50 * scale)
            $0.leading.trailing.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints {
            $0.height.equalTo(50 * scale)
            $0.leading.trailing.equalToSuperview()
        }

        twitterButton.snp.makeConstraints {
            $0.height.equalTo(50 * scale)
            $0.leading.trailing.equalToSuperview()
        }

//        whatsAppButton.snp.makeConstraints {
//            $0.height.equalTo(50 * scale)
//            $0.leading.trailing.equalToSuperview()
//        }
//
//        facebookButton.snp.makeConstraints {
//            $0.height.equalTo(50 * scale)
//            $0.leading.trailing.equalToSuperview()
//        }
    }
    
    private func bindAction() {
        exportButton.rx.tap
            .bind { [weak self] _ in
                self?.delegate?.selectedButton(type: .export)
            }
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .bind { [weak self] _ in
                self?.delegate?.selectedButton(type: .gallery)
            }
            .disposed(by: disposeBag)
        
        twitterButton.rx.tap
            .bind { [weak self] _ in
                self?.delegate?.selectedButton(type: .twitter)
            }
            .disposed(by: disposeBag)
    }
}
