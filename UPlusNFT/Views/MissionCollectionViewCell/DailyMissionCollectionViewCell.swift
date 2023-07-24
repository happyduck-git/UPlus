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
        label.font = .systemFont(ofSize: UPlusFont.head5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let missionTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.head6, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .white
        self.backgroundColor = .systemGray6
        self.setUI()
        self.setLayout()
        
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async {
            self.pointContainer.layer.cornerRadius = self.pointContainer.frame.height / 2
//            self.imageContainerView.heightAnchor.constraint(equalToConstant: self.contentView.frame.height * (3/5)).isActive = true
        }
    }
}

//MARK: - Configure with View Model
extension DailyMissionCollectionViewCell {
    func configure(with vm: DailyMissionCollectionViewCellViewModel) {
        
        Task {
            do {
                self.missionImage.image = try await URL.urlToImage(URL(string: vm.missionImage))
                self.pointLabel.text = String(describing: vm.missionPoint) + MissionConstants.pointUnit
                self.missionTitle.text = vm.missionTitle
            }
            catch {
                print("Error fetching mission image -- \(error.localizedDescription)")
            }
        }
        
    }
}

//MARK: - Set UI & Layout
extension DailyMissionCollectionViewCell {
    
    private func setUI() {
        self.contentView.addSubviews(self.imageContainerView,
                                     self.missionTitle)
        self.imageContainerView.addSubviews(self.missionImage,
                                            self.pointContainer)
        self.pointContainer.addSubview(self.pointLabel)
    }
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            self.imageContainerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.imageContainerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.imageContainerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.imageContainerView.heightAnchor.constraint(equalToConstant: self.contentView.frame.height * (2/3)),
            self.missionTitle.topAnchor.constraint(equalTo: self.imageContainerView.bottomAnchor),
            self.missionTitle.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.missionTitle.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.missionImage.topAnchor.constraint(equalTo: self.imageContainerView.topAnchor),
            self.missionImage.leadingAnchor.constraint(equalTo: self.imageContainerView.leadingAnchor),
            self.missionImage.trailingAnchor.constraint(equalTo: self.imageContainerView.trailingAnchor),
            self.missionImage.bottomAnchor.constraint(equalTo: self.imageContainerView.bottomAnchor),
            
            self.imageContainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.pointContainer.bottomAnchor, multiplier: 2),
            self.imageContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointContainer.trailingAnchor, multiplier: 2),
            self.pointContainer.heightAnchor.constraint(equalToConstant: self.contentView.frame.width / 5),
            self.pointContainer.widthAnchor.constraint(equalTo: self.pointContainer.heightAnchor)
        ])

        NSLayoutConstraint.activate([
            self.pointLabel.centerXAnchor.constraint(equalTo: self.pointContainer.centerXAnchor),
            self.pointLabel.centerYAnchor.constraint(equalTo: self.pointContainer.centerYAnchor)
        ])
    }
    
}
