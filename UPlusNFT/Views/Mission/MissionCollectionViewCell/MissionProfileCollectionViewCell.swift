//
//  MissionProfileCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/18.
//

import UIKit
import Nuke

final class MissionProfileCollectionViewCell: UICollectionViewCell {

    private var vm: UserProfileViewViewModel?
    
    //MARK: - Property
    private let levelUpNoticeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "다음 레벨 업까지\n미션 3개 남았어요!"
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelBadgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAssets.levelBadge)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pointImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAssets.pointSticker)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let totalPointLabel: UILabel = {
       let label = UILabel()
        label.textColor = .systemGray
        label.text = "9/12"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressBar: UIProgressView = {
        let bar = UIProgressView()
        bar.progress = 0.0
        bar.clipsToBounds = true
        bar.progressViewStyle = .default
        bar.backgroundColor = UPlusColor.gageBackgroundPink
        bar.progressTintColor = UPlusColor.pointGagePink
        bar.trackTintColor = .systemGray
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    private let certificateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "내 경험 인증서"
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let myMissionCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.identifier)
        collectionView.register(MyMissionsCollectionViewCell.self, forCellWithReuseIdentifier: MyMissionsCollectionViewCell.identifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Configure
extension MissionProfileCollectionViewCell {
    func configure(with vm: UserProfileViewViewModel) {
        self.vm = vm
        
        Task {
            do {
                let url = URL(string: vm.profileImage)
                
                self.levelLabel.text = "Lv." + String(describing: vm.level)
              
            }
            catch {
                print("Error fetching profileImage -- \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Set UI & Layout
extension MissionProfileCollectionViewCell {
    
    private func setUI() {
        self.contentView.addSubviews(
            levelUpNoticeLabel,
            levelBadgeImageView,
            levelLabel,
            pointImageView,
            totalPointLabel,
            progressBar,
            certificateLabel,
            myMissionCollectionView
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.levelUpNoticeLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.levelUpNoticeLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            
            self.levelBadgeImageView.topAnchor.constraint(equalTo: self.levelUpNoticeLabel.topAnchor),
            self.levelBadgeImageView.bottomAnchor.constraint(equalTo: self.levelUpNoticeLabel.bottomAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.levelBadgeImageView.trailingAnchor, multiplier: 2),
            
            self.levelLabel.centerXAnchor.constraint(equalTo: self.levelBadgeImageView.centerXAnchor),
            self.levelLabel.centerYAnchor.constraint(equalTo: self.levelBadgeImageView.centerYAnchor),
            
            self.pointImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.levelUpNoticeLabel.bottomAnchor, multiplier: 2),
            self.pointImageView.leadingAnchor.constraint(equalTo: self.levelUpNoticeLabel.leadingAnchor),
            
            self.totalPointLabel.topAnchor.constraint(equalTo: self.pointImageView.topAnchor),
            self.totalPointLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.pointImageView.trailingAnchor, multiplier: 1),
            
            self.progressBar.topAnchor.constraint(equalTo: self.pointImageView.topAnchor),
            self.progressBar.leadingAnchor.constraint(equalToSystemSpacingAfter: self.totalPointLabel.trailingAnchor, multiplier: 2),
            self.progressBar.bottomAnchor.constraint(equalTo: self.pointImageView.bottomAnchor),
            self.progressBar.widthAnchor.constraint(equalToConstant: 230),
            
            self.certificateLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.pointImageView.bottomAnchor, multiplier: 3),
            self.certificateLabel.leadingAnchor.constraint(equalTo: self.levelUpNoticeLabel.leadingAnchor),
            
            self.myMissionCollectionView.topAnchor.constraint(equalToSystemSpacingBelow: self.certificateLabel.bottomAnchor, multiplier: 2),
            self.myMissionCollectionView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.myMissionCollectionView.trailingAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.myMissionCollectionView.bottomAnchor, multiplier: 1)
        ])
    }
    
    private func setDelegate() {
        self.myMissionCollectionView.delegate = self
        self.myMissionCollectionView.dataSource = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async {
            // Set progress bar corner radius.
            self.progressBar.layer.cornerRadius = self.progressBar.frame.height / 2
            self.progressBar.layer.sublayers?[1].cornerRadius = self.progressBar.frame.height / 2
            self.progressBar.subviews[1].clipsToBounds = true
            
            /* Checking progress animation */
            self.progressBar.setProgress(0.9, animated: true)
        }

    }
  
}

extension MissionProfileCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyMissionsCollectionViewCell.identifier, for: indexPath) as? MyMissionsCollectionViewCell,
              let cellVM = self.vm
        else {
            return UICollectionViewCell()
        }
//        cell.configure(with: cellVM.missionVMList[indexPath.item])
        cell.missionLabel.text = "6000보 걷기"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.myMissionCollectionView.frame.height,
                      height: self.myMissionCollectionView.frame.height)
    }
    
}
