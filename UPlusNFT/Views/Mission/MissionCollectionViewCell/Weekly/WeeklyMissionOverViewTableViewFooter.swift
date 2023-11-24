//
//  WeeklyMissionOverViewTableViewFooter.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/28.
//

import UIKit

final class WeeklyMissionOverViewTableViewFooter: UIView {

    private let footerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
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

// MARK: - Configure with View Model
extension WeeklyMissionOverViewTableViewFooter {
    func configure(with vm: WeeklyMissionOverViewViewModel) {
        
        var footerImage: UIImage?
        
        switch vm.week {
        case 1:
            footerImage = UIImage(named: WeeklyEpisode.week1.footerImage)
            
        case 2:
            footerImage = UIImage(named: WeeklyEpisode.week2.footerImage)
            
        default:
            footerImage = UIImage(named: WeeklyEpisode.week3.footerImage)
        }
        
        self.footerImage.image = footerImage
    }
    
}

extension WeeklyMissionOverViewTableViewFooter {
    private func setUI() {
        self.addSubview(self.footerImage)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.footerImage.topAnchor.constraint(equalTo: self.topAnchor),
            self.footerImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.footerImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.footerImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
}
