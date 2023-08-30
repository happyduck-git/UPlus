//
//  YesterdayRankerTableViewCell.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/24.
//

import UIKit
import FirebaseFirestore
import Nuke

final class YesterdayRankerTableViewCell: UITableViewCell {

    private let titleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.yesterdayTitle)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let medalImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.goldMedal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UPlusColor.gray02
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let rankerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UPlusColor.gray09
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
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
        label.textAlignment = .center
        label.textColor = UPlusColor.gray09
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
   
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = .white
        self.contentView.layer.borderColor = UPlusColor.yellow01.cgColor
        self.contentView.layer.borderWidth = 4.0
        
        self.setUI()
        self.setLayout()
        self.setupShadow()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 20, left: 30, bottom: 20, right: 30))
    }
}

//MARK: - Configure
extension YesterdayRankerTableViewCell {
    func configure(ranker: UPlusUser?, doc: DocumentReference??) {
        
        guard let ranker = ranker else {
            self.rankerLabel.text = "랭커가 없습니다!"
            self.pointLabel.text = String(describing: 0)
            return
        }
        
        self.medalImage.isHidden = false
        self.profileImageView.isHidden = false
        self.rankerLabel.text = ranker.userNickname
        self.pointLabel.text = String(describing: ranker.userTotalPoint ?? 0)
        
        guard let document = doc,
              let realDoc = document
        else { return }
        
        Task {
            do {
                let doc = try await realDoc.getDocument()
                let imageUrl = doc[FirestoreConstants.nftContentImageUrl] as? String ?? ""
                guard let url = URL(string: imageUrl) else { return }
                self.profileImageView.image = try await ImagePipeline.shared.image(for: url)
            }
            catch {
                UPlusLogger.logger.error("Error getting imagurl from nft document -- \(String(describing: error))")
            }
        }
    }
}

//MARK: - Private
extension YesterdayRankerTableViewCell {
    private func setupShadow() {
           self.contentView.layer.masksToBounds = false
           self.contentView.layer.shadowColor = UIColor.black.cgColor
           self.contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
           self.contentView.layer.shadowOpacity = 0.2
           self.contentView.layer.shadowRadius = 4.0
       }
}

//MARK: - Set UI & Layout
extension YesterdayRankerTableViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.titleImage,
                                     self.medalImage,
                                     self.profileImageView,
                                     self.rankerLabel,
                                     self.pointImage,
                                     self.pointLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.titleImage.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.titleImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 5),
            self.titleImage.heightAnchor.constraint(equalToConstant: 30),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleImage.trailingAnchor, multiplier: 5),
            
            self.medalImage.topAnchor.constraint(equalToSystemSpacingBelow: self.titleImage.bottomAnchor, multiplier: 1),
            self.medalImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 3),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.medalImage.bottomAnchor, multiplier: 2),
            
            self.profileImageView.topAnchor.constraint(equalTo: self.medalImage.topAnchor),
            self.profileImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.medalImage.trailingAnchor, multiplier: 2),
            self.profileImageView.bottomAnchor.constraint(equalTo: self.medalImage.bottomAnchor),
            self.profileImageView.widthAnchor.constraint(equalTo: self.profileImageView.heightAnchor),
            
            self.rankerLabel.centerYAnchor.constraint(equalTo: self.medalImage.centerYAnchor),
            self.rankerLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileImageView.trailingAnchor, multiplier: 1),
            
            self.pointImage.centerYAnchor.constraint(equalTo: self.rankerLabel.centerYAnchor),
            self.pointImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.rankerLabel.trailingAnchor, multiplier: 6),
//            self.pointImage.bottomAnchor.constraint(equalTo: self.rankerLabel.bottomAnchor),
            
            self.pointLabel.centerYAnchor.constraint(equalTo: self.pointImage.centerYAnchor),
            self.pointLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.pointImage.trailingAnchor, multiplier: 1),
//            self.pointLabel.bottomAnchor.constraint(equalTo: self.pointImage.bottomAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 3)
        ])
    }
}
