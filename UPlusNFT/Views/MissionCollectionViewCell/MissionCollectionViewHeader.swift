//
//  MissionCollectionViewHeader.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/17.
//

import UIKit

protocol MissionCollectionViewHeaderProtocol: AnyObject {
    func levelUpButtonDidTap()
}

final class MissionCollectionViewHeader: UICollectionReusableView {
        
    //MARK: - Delegate
    weak var delegate: MissionCollectionViewHeaderProtocol?
    
    //MARK: - Property
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let verticalBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: SFSymbol.info), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let levelBadge: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.levelPrefix + "1"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 11.0)
        label.backgroundColor = .systemPink
        label.clipsToBounds = true
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "15/10"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressBar: UIProgressView = {
        let bar = UIProgressView()
        bar.progress = 0.0
        bar.clipsToBounds = true
        bar.progressViewStyle = .default
        bar.progressTintColor = .systemPink
        bar.trackTintColor = .systemGray
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    private let levelUpButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle(MissionConstants.levelUp, for: .normal)
        button.backgroundColor = .systemGray2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
}

// MARK: - Set UI & Layout
extension MissionCollectionViewHeader {
    
    private func setUI() {
        
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
        
        ])
    }
    
}
