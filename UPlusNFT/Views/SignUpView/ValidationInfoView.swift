//
//  ValidationInfoView.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/31.
//

import UIKit

final class ValidationInfoView: UIView {

    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2.0
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let image: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAssets.infoRed)
        return imageView
    }()
    
    private let desc: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.textColor = UPlusColor.orange01
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension ValidationInfoView {
    func setTitleText(_ text: String) {
        self.desc.text = text
    }
}

//MARK: -  Set UI Layout
extension ValidationInfoView {
    private func setUI() {
        self.addSubviews(self.stack)
        self.stack.addArrangedSubviews(self.image,
                                       self.desc)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.stack.topAnchor.constraint(equalTo: self.topAnchor),
            self.stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.stack.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ValidationInfoView_Preview: PreviewProvider{
    static var previews: some View {
        UIViewPreview {
            let view = ValidationInfoView(frame: .zero)
            return view
        }.previewLayout(.sizeThatFits)
    }
}
#endif
