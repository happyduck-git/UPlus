//
//  DailyMissionCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/18.
//

import UIKit

class DailyMissionCollectionViewCell: UICollectionViewCell {
    
    private let imageContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let missionImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let pointContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = UPlusColor.pointCirclePink
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pointLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: UPlusFont.head3, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let missionTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.head4, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async {
            self.containerView.layer.cornerRadius = self.containerView.frame.width / 11
            self.pointContainer.layer.cornerRadius = self.pointContainer.frame.height / 2
        }
    }
}


