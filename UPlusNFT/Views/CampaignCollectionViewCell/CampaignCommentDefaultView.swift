//
//  CampaignCommentDefaultView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/10.
//

import UIKit

final class CampaignCommentDefaultView: UIView {
    
    // MARK: - UI Elements
    let commentTexts: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.lineBreakMode = .byTruncatingMiddle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let commentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: SFSymbol.camera)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        setLayout()
    }
}

extension CampaignCommentDefaultView {
    private func setUI() {
        self.addSubviews(commentTexts,
                         commentImage)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            commentTexts.topAnchor.constraint(equalTo: self.topAnchor),
            commentTexts.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            commentTexts.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            commentImage.topAnchor.constraint(equalToSystemSpacingBelow: commentTexts.bottomAnchor, multiplier: 1),
            commentImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            commentImage.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        self.commentTexts.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

extension CampaignCommentDefaultView {
    func configure(with vm: CommentTableViewCellModel) {
        commentTexts.text = vm.comment
        Task {
            guard let image = vm.imagePath,
                  let url = URL(string: image)
            else {
                self.commentImage.isHidden = true
                return
            }

            do {
                let photo = try await URL.urlToImage(url)
                self.commentImage.image = photo
            }
            catch {
                print("Error fetching comment image \(error)")
            }
            
        }
    }
}
