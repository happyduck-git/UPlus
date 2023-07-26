//
//  MyMissionsCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/25.
//

import UIKit

final class MyMissionsCollectionViewCell: UICollectionViewCell {
    
    //MARK: - UI Elements
    private let progressCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let missionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let outerShape = CAShapeLayer()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setUI()
        self.setLayout()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async {
            self.setTrackShape()
            self.setProgress()
        }
        
    }
}

extension MyMissionsCollectionViewCell {
    func configure(with vm: MyMissionsCollectionViewCellViewModel) {
        self.missionLabel.text = vm.missionTitle
    }
}

extension MyMissionsCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.progressCircle,
                                     self.missionLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.progressCircle.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.progressCircle.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.progressCircle.trailingAnchor, multiplier: 1),
            self.progressCircle.heightAnchor.constraint(equalToConstant: self.contentView.frame.height / 2),
            
            self.missionLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.progressCircle.bottomAnchor, multiplier: 1),
            self.missionLabel.leadingAnchor.constraint(equalTo: self.progressCircle.leadingAnchor),
            self.missionLabel.trailingAnchor.constraint(equalTo: self.progressCircle.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.missionLabel.bottomAnchor, multiplier: 1)
        ])
        self.missionLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

extension MyMissionsCollectionViewCell {
    
    private func setTrackShape() {
        let circleCenter = CGPoint(x: self.progressCircle.bounds.midX, y: self.progressCircle.bounds.midY)
        let circlePath = UIBezierPath(
            arcCenter: circleCenter,
            radius: 20,
            startAngle: -(.pi / 2),
            endAngle: .pi * 2,
            clockwise: true
        )
        
        let trackShape = CAShapeLayer()
        trackShape.path = circlePath.cgPath
        trackShape.fillColor = UIColor.clear.cgColor
        trackShape.lineWidth = 5
        trackShape.strokeColor = UPlusColor.gageBackgroundPink.cgColor
        self.progressCircle.layer.addSublayer(trackShape)
        
        self.outerShape.path = circlePath.cgPath
        self.outerShape.lineWidth = 5
        self.outerShape.strokeEnd = 0
        self.outerShape.lineCap = .round
        self.outerShape.strokeColor = UPlusColor.pointGagePink.cgColor
        self.outerShape.fillColor = UIColor.clear.cgColor
        self.progressCircle.layer.addSublayer(self.outerShape)
    }
    
    func setProgress() {
        //    func setProgress(from initialPoint: CGFloat, to newPoint: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.4
        animation.toValue = 0.50
        animation.duration = 1.0
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        self.outerShape.add(animation, forKey: "circle-animation")
    }
}
