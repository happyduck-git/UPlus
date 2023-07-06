//
//  CommentCampaignViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/04.
//

import UIKit
import Combine

final class CommentCampaignCollectionViewCell: UICollectionViewCell, CampaignCell {
    
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let campaignView: CampaignView = {
        let view = CampaignView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let missionTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textAlignment = .center
        label.text = PostConstants.tempMissionSentence
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemGray3
        
        setUI()
        setLayout()
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Set UI & Layout
    private func setUI() {
        contentView.addSubviews(
            campaignView,
            missionTextLabel
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.campaignView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.campaignView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 3),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.campaignView.trailingAnchor, multiplier: 3),
            //TODO: Set height according to the contents size
            self.campaignView.heightAnchor.constraint(equalToConstant: 150),
          
            self.missionTextLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.campaignView.bottomAnchor, multiplier: 1),
            self.missionTextLabel.leadingAnchor.constraint(equalTo: self.campaignView.leadingAnchor),
            self.missionTextLabel.trailingAnchor.constraint(equalTo: self.campaignView.trailingAnchor),
        
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.missionTextLabel.bottomAnchor, multiplier: 2)
        ])
        self.missionTextLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    // MARK: - Private
  
    
    // MARK: - Internal
    func bind(with vm: CampaignCollectionViewCellViewModel) {
        func bindViewToViewModel() {

        }
        
        func bindViewModelToView() {
            vm.$campaignMetadata
                .receive(on: DispatchQueue.main)
                .sink { [weak self] metadata in
                    guard let `self` = self else { return }
                    vm.createData()

                    // Bind other data
                    self.campaignView.configure(with: vm)
                }
                .store(in: &bindings)
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}
