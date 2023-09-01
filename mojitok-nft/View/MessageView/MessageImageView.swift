//
//  MessageView.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/27.
//

import UIKit
import SnapKit

final class MessageImageView: UIView {
    
    public var title: String = "" {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.textLabel.text = self.title
            }
        }
    }
    
    private lazy var iconImageView = UIImageView().then {
        $0.setImage(.check)
        addSubview($0)
    }
    
    private lazy var textLabel = UILabel().then {
        $0.font = .body03
        $0.textColor = .white01
        addSubview($0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        self.backgroundColor = .bg
        layer.cornerRadius = 8 * scale
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.2
        
        iconImageView.snp.makeConstraints {
            $0.width.height.equalTo(20 * scale)
            $0.leading.equalToSuperview().offset(10 * scale)
            $0.centerY.equalToSuperview()
        }
        
        textLabel.snp.makeConstraints {
            $0.height.equalTo(20 * scale)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(10 * scale)
            $0.trailing.equalToSuperview().offset(-10 * scale)
            $0.centerY.equalToSuperview()
        }
    }
}

final class MessageView: UIView {

    public var title: String = "" {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.textLabel.text = self.title
            }
        }
    }

    private lazy var textLabel = UILabel().then {
        $0.font = .body03
        $0.textColor = .white01
        addSubview($0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setLayout() {
        self.backgroundColor = .bg
        layer.cornerRadius = 8 * scale

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.2
        
        textLabel.snp.makeConstraints {
            $0.height.equalTo(20 * scale)
            $0.leading.equalToSuperview().offset(10 * scale)
            $0.trailing.equalToSuperview().offset(-10 * scale)
            $0.centerY.equalToSuperview()
        }
    }
}
