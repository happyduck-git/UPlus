//
//  DailyRoutainStampCollectionViewCellHeader.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/31.
//

import UIKit
import Combine

final class DailyRoutainStampCollectionViewCellHeader: UICollectionViewCell {
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let quizDescription: UILabel = {
        let label = UILabel()
        label.text = "갓생미션 인증서와 300만원 경품권을 받으세요!"
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: UPlusFont.head5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quizTitle: UILabel = {
        let label = UILabel()
        label.text = "매일 6000보 걷기"
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: UPlusFont.main, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let eventContentView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let eventLabel: UILabel = {
        let label = UILabel()
        label.text = "이벤트 기간 D-23"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .systemGray5
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
// 
// MARK: - Configure
extension DailyRoutainStampCollectionViewCellHeader {
    func bind(with vm: DailyRoutineMissionDetailViewViewModel) {
        
        bindings.forEach { $0.cancel() }
        bindings.removeAll()
        
        vm.$daysLeft
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.eventLabel.text = "이벤트 기간 D-" + $0
            }
            .store(in: &bindings)
    }
}

// MARK: - Set UI & Layout
extension DailyRoutainStampCollectionViewCellHeader {
    private func setUI() {
        self.contentView.addSubviews(self.quizDescription,
                                     self.quizTitle,
                                     self.eventContentView)
        
        self.eventContentView.addSubview(self.eventLabel)
        self.eventContentView.layer.cornerRadius = 10
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.quizDescription.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.quizDescription.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.contentView.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.quizDescription.trailingAnchor, multiplier: 2),
            
            self.quizTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.quizDescription.bottomAnchor, multiplier: 1),
            self.quizTitle.leadingAnchor.constraint(equalTo: self.quizDescription.leadingAnchor),
            self.quizTitle.trailingAnchor.constraint(equalTo: self.quizDescription.trailingAnchor),
            
            self.eventContentView.topAnchor.constraint(equalToSystemSpacingBelow: self.quizTitle.bottomAnchor, multiplier: 2),
            self.eventContentView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.eventContentView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizTitle.leadingAnchor, multiplier: 10),
            self.quizTitle.trailingAnchor.constraint(equalToSystemSpacingAfter: self.eventContentView.trailingAnchor, multiplier: 10),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.eventContentView.bottomAnchor, multiplier: 1)
        ])
        
        NSLayoutConstraint.activate([
            self.eventLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.eventContentView.topAnchor, multiplier: 1),
            self.eventLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.eventContentView.leadingAnchor, multiplier: 1),
            self.eventContentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.eventLabel.trailingAnchor, multiplier: 1),
            self.eventContentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.eventLabel.bottomAnchor, multiplier: 1)
        ])
        
    }
}
