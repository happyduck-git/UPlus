//
//  RoutineUploadPhotoView.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/18.
//

import UIKit
import Combine

final class RoutineUploadPhotoButton: UIButton {
    
    //MARK: - UI Elements
    private let uploadImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAssets.uploadGray)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let uploadLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = MissionConstants.upload
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.textColor = UPlusColor.gray06
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.infoLabel.attributedText = self.setAttributedText()
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Private
extension RoutineUploadPhotoButton {
    private func setAttributedText() -> NSAttributedString {
        let font: UIFont = .systemFont(ofSize: UPlusFont.caption1, weight: .semibold)
        let attributedString = NSMutableAttributedString(string: MissionConstants.routineDesc, attributes: [
            .font: font,
            .foregroundColor: UPlusColor.gray06
        ])
        
        if let range1 = attributedString.string.range(of: MissionConstants.routineDate),
           let range2 = attributedString.string.range(of: MissionConstants.routineTodo)
        {
            let nsRange1 = NSRange(range1, in: attributedString.string)
            let nsRange2 = NSRange(range2, in: attributedString.string)
            attributedString.addAttributes([
                .foregroundColor: UPlusColor.blue04,
                .font: font
            ], range: nsRange1)
            attributedString.addAttributes([
                .foregroundColor: UPlusColor.blue04,
                .font: font
            ], range: nsRange2)
        }
        
        return attributedString
    }
    
}

extension RoutineUploadPhotoButton {
    private func setUI() {
        self.addSubviews(self.uploadImage,
                         self.uploadLabel,
                         self.infoLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.uploadImage.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 2),
            self.uploadImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.uploadLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.uploadImage.bottomAnchor, multiplier: 2),
            self.uploadLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.uploadLabel.trailingAnchor, multiplier: 2),
            
            self.infoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.uploadLabel.bottomAnchor, multiplier: 2),
            self.infoLabel.leadingAnchor.constraint(equalTo: self.uploadLabel.leadingAnchor),
            self.infoLabel.trailingAnchor.constraint(equalTo: self.uploadLabel.trailingAnchor),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.infoLabel.bottomAnchor, multiplier: 2)
        ])

        self.infoLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct RoutineUploadPhotoPreView: PreviewProvider{
    static var previews: some View {
        UIViewPreview {
            let view = RoutineUploadPhotoButton(frame: .zero)
            return view
        }.previewLayout(.sizeThatFits)
    }
}
#endif
