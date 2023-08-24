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
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let container: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 8.0
        view.backgroundColor = UPlusColor.grayBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = UPlusColor.gray03
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingMiddle
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
                         self.container)
        
        self.container.addSubviews(self.profileImage,
                                   self.usernameLabel,
                                   self.pointImage,
                                   self.pointLabel)
    }
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            self.medalImage.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1),
            self.medalImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.medalImage.widthAnchor.constraint(equalToConstant: 35),
            self.medalImage.heightAnchor.constraint(equalToConstant: 35),
            
            self.container.topAnchor.constraint(equalToSystemSpacingBelow: self.medalImage.bottomAnchor, multiplier: 1),
            self.container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.container.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.container.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.profileImage.topAnchor.constraint(equalToSystemSpacingBelow: self.container.topAnchor, multiplier: 2),
            self.profileImage.centerXAnchor.constraint(equalTo: self.container.centerXAnchor),
            self.profileImage.widthAnchor.constraint(equalToConstant: 48),
            self.profileImage.heightAnchor.constraint(equalToConstant: 48),

            self.usernameLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.profileImage.bottomAnchor, multiplier: 2),
            self.usernameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.container.leadingAnchor, multiplier: 2),
            self.container.trailingAnchor.constraint(equalToSystemSpacingAfter: self.usernameLabel.trailingAnchor, multiplier: 2),

            self.pointImage.topAnchor.constraint(equalToSystemSpacingBelow: self.usernameLabel.bottomAnchor, multiplier: 2),
            self.pointImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.container.leadingAnchor, multiplier: 2),

            self.pointLabel.topAnchor.constraint(equalTo: self.pointImage.topAnchor),
            self.pointLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.pointImage.trailingAnchor, multiplier: 1),
            self.container.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 2),
            self.container.bottomAnchor.constraint(equalToSystemSpacingBelow: self.pointLabel.bottomAnchor, multiplier: 2)
        ])
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
