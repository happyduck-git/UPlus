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
        imageView.image = UIImage(named: ImageAssets.checkBlack)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView()
        progress.isHidden = true
        progress.trackTintColor = .white
        progress.progressTintColor = UPlusColor.gray02
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textColor = UPlusColor.gray05
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
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
    
    func setProgress(progress: Float) {
        self.progressView.setProgress(progress, animated: true)
        self.progressLabel.text = String(format: MissionConstants.progressSuffix, (progress * 100))
       
        self.progressView.isHidden = false
        self.progressLabel.isHidden = false
        self.checkmark.isHidden = true
        self.isUserInteractionEnabled = false
    }
}

extension ChoiceMultipleQuizButton {
    private func setUI() {
        self.addSubviews(self.progressView,
                         self.quizCaption,
                         self.progressLabel,
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
        
        NSLayoutConstraint.activate([
            self.progressView.topAnchor.constraint(equalTo: self.topAnchor),
            self.progressView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.progressView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.progressView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.progressLabel.topAnchor.constraint(equalTo: self.checkmark.topAnchor),
            self.progressLabel.trailingAnchor.constraint(equalTo: self.checkmark.trailingAnchor),
            self.progressLabel.bottomAnchor.constraint(equalTo: self.checkmark.bottomAnchor)
        ])
    }
}
