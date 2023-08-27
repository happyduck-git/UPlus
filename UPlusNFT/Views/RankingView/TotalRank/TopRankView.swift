//
//  TopRankView.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/23.
//

import UIKit
import Nuke

final class TopRankView: UIView {

    //MARK: - UI Elements
    private let medalImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UPlusColor.gray03
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        label.textColor = UPlusColor.gray09
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pointImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.point)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let pointLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray09
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.layer.borderColor = UPlusColor.blue01.cgColor
        self.layer.borderWidth = 4.0
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.height / 2
    }
    
}

//MARK: - Configure
extension TopRankView {
    
    func configure(image: String,
                   username: String,
                   point: Int64) {
        
        self.usernameLabel.text = username
        self.pointLabel.text = String(describing: point)
        
        Task {
            do {
                guard let url = URL(string: image) else { return }
                self.profileImage.image = try await ImagePipeline.shared.image(for: url)
            }
            catch {
                UPlusLogger.logger.error("Error fetching profile image -- \(String(describing: error))")
            }
        }

    }
    
}

//MARK: - Public
extension TopRankView {
    func setMedalImage(name: String) {
        self.medalImage.image = UIImage(named: name)
    }
}

//MARK: - Set UI & Layout
extension TopRankView {
    
    private func setUI() {
        self.addSubviews(self.medalImage,
                         self.profileImage,
                         self.usernameLabel,
                         self.pointImage,
                         self.pointLabel)
    }
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            self.medalImage.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1),
            self.medalImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.medalImage.bottomAnchor, multiplier: 1),
            
            self.profileImage.topAnchor.constraint(equalTo: self.medalImage.topAnchor),
            self.profileImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.medalImage.trailingAnchor, multiplier: 2),
            self.profileImage.widthAnchor.constraint(equalTo: self.profileImage.heightAnchor),
            self.profileImage.bottomAnchor.constraint(equalTo: self.medalImage.bottomAnchor),
            
            self.usernameLabel.centerYAnchor.constraint(equalTo: self.profileImage.centerYAnchor),
            self.usernameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileImage.trailingAnchor, multiplier: 1),
            
            self.pointImage.topAnchor.constraint(equalTo: self.profileImage.topAnchor),
            self.pointImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.usernameLabel.trailingAnchor, multiplier: 2),
            self.pointImage.bottomAnchor.constraint(equalTo: self.profileImage.bottomAnchor),
            
            self.pointLabel.centerYAnchor.constraint(equalTo: self.pointImage.centerYAnchor),
            self.pointLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.pointImage.trailingAnchor, multiplier: 1),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 2)
        ])
        
        self.medalImage.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.pointImage.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.pointLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.profileImage.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.usernameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct TopRankViewPreView: PreviewProvider{
    static var previews: some View {
        UIViewPreview {
            let view = TopRankView(frame: .zero)
            return view
        }.previewLayout(.sizeThatFits)
    }
}
#endif
