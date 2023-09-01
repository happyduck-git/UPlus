//
//  TopBar.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/01/28.
//

import UIKit

import RxCocoa
import RxSwift
import Pure

protocol TopBarDelegate: AnyObject {
    func didTapLeadingButton()
    func didTapTrailingButton()
}

final class TopBar: UIView, FactoryModule {
    
    struct Dependency {
    }
    
    struct Payload {
        let title: String
        let isIdenticon: Bool
    }
    
    private lazy var leadingButton = UIButton().then {
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 12)
        $0.setTitleColor(.blue, for: .normal)
        $0.isHidden = true
        addSubview($0)
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.textColor = .white01
        $0.font = .subtitle01
        $0.isHidden = true
        addSubview($0)
    }
    
    private lazy var trailingButton = UIButton().then {
        $0.layer.masksToBounds = true
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 12)
        $0.setTitleColor(.blue, for: .normal)
        $0.isHidden = true
        addSubview($0)
    }
    
    var title: String = "" {
        didSet {
            if title != "" {
                titleLabel.isHidden = false
                titleLabel.text = title
            }
        }
    }
    
    weak var delegate: TopBarDelegate?
    var disposedBag = DisposeBag()
    private let dependency: Dependency
    private let payload: Payload
    
    init(dependency: Dependency, payload: Payload) {
        self.dependency = dependency
        self.payload = payload
        
        super.init(frame: .zero)
        
        setUI()
        setState()
        setAction()
        
        title = payload.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        leadingButton.snp.makeConstraints {
            $0.width.equalTo(0)
            $0.height.equalTo(44 * scale)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10 * scale)
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(44 * scale)
            $0.bottom.equalToSuperview().offset(-10 * scale)
            $0.leading.equalTo(leadingButton.snp.trailing).offset(15 * scale)
        }
        
        trailingButton.snp.makeConstraints {
            $0.width.equalTo(0)
            $0.height.equalTo(44 * scale)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(15 * scale)
            $0.trailing.equalToSuperview().offset(-15 * scale)
            $0.bottom.equalToSuperview().offset(-10 * scale)
        }
    }
    
    private func setAction() {
        leadingButton.rx.tap
            .bind { _ in
                self.delegate?.didTapLeadingButton()
            }
            .disposed(by: disposedBag)
        
        trailingButton.rx.tap
            .bind { _ in
                self.delegate?.didTapTrailingButton()
            }
            .disposed(by: disposedBag)
    }
    
    private func setState() {
        
    }
    
    func setLeadingItem(mjtImage: MJTImage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.leadingButton.isHidden = false
            self.leadingButton.setImage(mjtImage)
            self.leadingButton.snp.updateConstraints {
                $0.width.equalTo(44 * scale)
            }
        }
    }
    
    func setTrailingItem(mjtImage: MJTImage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.trailingButton.isHidden = false
            self.trailingButton.setImage(mjtImage)
            self.trailingButton.snp.updateConstraints {
                $0.width.equalTo(44 * scale)
            }
        }
    }
}
