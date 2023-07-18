//
//  DailyMissionCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/18.
//

import UIKit

class DailyMissionCollectionViewCell: UICollectionViewCell {
    
    private let missionImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let missionTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.head4, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
 
}
