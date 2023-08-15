//
//  ChoiceMultipleQuizButton.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/15.
//

import UIKit

final class ChoiceMultipleQuizButton: UIButton {
    
    private let quizCaption: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray09
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkmark: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.checkBlack)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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

extension ChoiceMultipleQuizButton {
    func setQuizTitle(text: String) {
        self.quizCaption.text = text
    }
    
    func toggleImage(hidden: Bool) {
        self.checkmark.isHidden = hidden
    }
}

extension ChoiceMultipleQuizButton {
    private func setUI() {
        self.addSubviews(self.quizCaption,
                         self.checkmark)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.quizCaption.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1),
            self.quizCaption.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.quizCaption.bottomAnchor, multiplier: 1),
            
            self.checkmark.topAnchor.constraint(equalTo: quizCaption.topAnchor),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.checkmark.trailingAnchor, multiplier: 2),
            self.checkmark.bottomAnchor.constraint(equalTo: quizCaption.bottomAnchor)
        ])
    }
}
