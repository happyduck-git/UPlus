//
//  RankBottomFlatSheetView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/24.
//

import UIKit
import Combine

final class RankBottomFlatSheetView: PassThroughView {

    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0.0, height: -5)
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pointLabel: UILabel = {
       let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()

        self.setTopBorder()
        
    }
    
}

// MARK: - Set UI & Layout
extension RankBottomFlatSheetView {
    func bind(with vm: RankingViewViewModel, at item: Int) {
        if item == 0 {
            vm.$currentUserTodayRank
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    self.pointLabel.text = "Today Point: " + String(describing: $0?.userPointHistory?.first?.userPointCount ?? 0)
                }
                .store(in: &bindings)
        } else {
            vm.$currentUserTotalRank
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    self.pointLabel.text = "Total Point: " + String(describing: $0?.userPointHistory?.first?.userPointCount ?? 0)
                }
                .store(in: &bindings)
        }
        
    }
}

// MARK: - Set UI & Layout
extension RankBottomFlatSheetView {
    private func setUI() {
        self.addSubviews(self.bottomSheetView)
        self.bottomSheetView.addSubviews(self.pointLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.bottomSheetView.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 80),
            self.bottomSheetView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.bottomSheetView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.bottomSheetView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.pointLabel.topAnchor.constraint(equalTo: self.bottomSheetView.topAnchor),
            self.pointLabel.leadingAnchor.constraint(equalTo: self.bottomSheetView.leadingAnchor),
            self.pointLabel.trailingAnchor.constraint(equalTo: self.bottomSheetView.trailingAnchor),
            self.pointLabel.bottomAnchor.constraint(equalTo: self.bottomSheetView.bottomAnchor)
        ])
    }
    
    private func setTopBorder() {
        let topLayer = CALayer()
        topLayer.backgroundColor = UIColor.black.cgColor
        topLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 1)
        self.bottomSheetView.layer.addSublayer(topLayer)
    }
}
