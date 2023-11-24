//
//  GiftDetailView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/18.
//

import UIKit
import Nuke

final class GiftDetailView: UIView {

    private let giftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UPlusColor.gray02.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nftTypeLabel: InsetLabelView = {
        let label = InsetLabelView()
        label.clipsToBounds = true
        label.setNameTitle(text: "래플권")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nftNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.h1, weight: .bold)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.giftImageView.widthAnchor.constraint(equalToConstant: self.frame.width / 2.5).isActive = true
        
        self.nftTypeLabel.layer.cornerRadius = self.nftTypeLabel.frame.height / 2
    }
    
}

// MARK: - Set UI & Layout
extension GiftDetailView {
    private func setUI() {
        self.addSubviews(self.giftImageView,
                         self.nftTypeLabel,
                         self.nftNameLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.giftImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1),
            self.giftImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 3),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.giftImageView.bottomAnchor, multiplier: 1),
            
            self.nftTypeLabel.topAnchor.constraint(equalTo: self.giftImageView.topAnchor),
            self.nftTypeLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.giftImageView.trailingAnchor, multiplier: 2),
            self.nftTypeLabel.widthAnchor.constraint(equalToConstant: 70),
            
            self.nftNameLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.nftTypeLabel.bottomAnchor, multiplier: 1),
            self.nftNameLabel.leadingAnchor.constraint(equalTo: self.nftTypeLabel.leadingAnchor),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.nftNameLabel.trailingAnchor, multiplier: 2)
        ])
    }
}

// MARK: - Public
extension GiftDetailView {
    func configure(imageUrl: String, nftName: String) {
        Task {
            self.nftNameLabel.text = nftName
            guard let url = URL(string: imageUrl) else { return }
            self.giftImageView.image = try await ImagePipeline.shared.image(for: url)
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct GiftDetailViewPreView: PreviewProvider{
    static var previews: some View {
        UIViewPreview {
            let view = GiftDetailView(frame: .zero)
            return view
        }.previewLayout(.sizeThatFits)
    }
}
#endif
