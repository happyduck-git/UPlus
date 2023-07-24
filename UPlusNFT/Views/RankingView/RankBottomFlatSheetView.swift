//
//  RankBottomFlatSheetView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/24.
//

import UIKit

final class RankBottomFlatSheetView: UIView {

    // MARK: - UI Elements
    let bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0.0, height: -5)
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    private func setUI() {
        self.addSubviews(self.bottomSheetView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.bottomSheetView.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 80),
            self.bottomSheetView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.bottomSheetView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.bottomSheetView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func setTopBorder() {
        let topLayer = CALayer()
        topLayer.backgroundColor = UIColor.black.cgColor
        topLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 1)
        self.bottomSheetView.layer.addSublayer(topLayer)
    }
}

// MARK: - Hit Test Set Up
extension RankBottomFlatSheetView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }
}
