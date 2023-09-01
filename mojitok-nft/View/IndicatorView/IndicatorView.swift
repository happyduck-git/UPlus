//
//  IndicatorView.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/06/27.
//

import UIKit

final class IndicatorView: UIView {
    
    private lazy var indicator = UIActivityIndicatorView().then {
        $0.layer.cornerRadius = 12 * scale
        $0.startAnimating()
        $0.backgroundColor = .white01
        addSubview($0)
    }
    
    init() {
        super.init(frame: .zero)
        
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        self.backgroundColor = .bg.withAlphaComponent(0.5)
        
        indicator.snp.makeConstraints {
            $0.width.height.equalTo(60 * scale)
            $0.center.equalToSuperview()
        }
    }
}
