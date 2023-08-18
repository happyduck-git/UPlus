//
//  TextReCheckLabelView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/18.
//

import UIKit

final class TextReCheckLabelView: UIView {
    
    // MARK: - UI Elements

    private let infoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.image = UIImage(systemName: SFSymbol.info)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Public
extension TextReCheckLabelView {
    func setLabelColor(_ color: UIColor) {
        self.infoImage.image?.withTintColor(color, renderingMode: .alwaysOriginal)
        self.infoLabel.textColor = color
    }
    
    func setLabelText(_ text: String) {
        self.infoLabel.text = text
        self.infoImage.isHidden = false
        self.infoLabel.isHidden = false
    }
    
    func hideInfoImageAndText() {
        self.infoLabel.isHidden = true
        self.infoImage.isHidden = true
    }
}

// MARK: - Set UI & Layout
extension TextReCheckLabelView {
    
    private func setUI() {
        self.addSubviews(self.infoImage,
                         self.infoLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.infoImage.topAnchor.constraint(equalTo: self.infoLabel.topAnchor),
            self.infoImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.infoImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.infoLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.infoLabel.leadingAnchor.constraint(equalTo: self.infoImage.trailingAnchor),
            self.infoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.infoLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
}
#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct TextReCheckLabelViewPreView: PreviewProvider{
    static var previews: some View {
        UIViewPreview {
            let view = TextReCheckLabelView(frame: .zero)
            return view
        }.previewLayout(.sizeThatFits)
    }
}
#endif
