//
//  RankingMenuBar.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/24.
//

import UIKit
import Combine

protocol RankingMenuBarDelegate: AnyObject {
    func didSelectItemAt(index: Int)
}

final class RankingMenuBar: UIView {
    
    // MARK: - Delegate
    weak var delegate: RankingMenuBarDelegate?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private var buttons: [UIButton] = []
    private var indicatorLeading: NSLayoutConstraint?
    private var indicatorTrailing: NSLayoutConstraint?
    private let leadPadding: CGFloat = 16
    private let buttonSpace: CGFloat = 6
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let todayRankButton: UIButton = {
        let button = UIButton()
        button.setTitle(RankingConstants.todayRank, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .semibold)
        button.setTitleColor(UPlusColor.mint04, for: .normal)
        return button
    }()
    
    private let totalRankButton: UIButton = {
        let button = UIButton()
        button.setTitle(RankingConstants.totalRank, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .semibold)
        button.setTitleColor(UPlusColor.mint04, for: .normal)
        return button
    }()
    
    private let indicatorBar: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white

        self.buttons = [todayRankButton, totalRankButton]
        self.setUI()
        self.setLayout()
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Set UI & Layout
extension RankingMenuBar {
    private func bind() {
        self.todayRankButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.delegate?.didSelectItemAt(index: 0)
            }
            .store(in: &bindings)
        
        self.totalRankButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.delegate?.didSelectItemAt(index: 1)
            }
            .store(in: &bindings)
    }
}

// MARK: - Set UI & Layout
extension RankingMenuBar {
    private func setUI() {
        self.addSubviews(self.buttonStack,
                        self.indicatorBar)
        self.buttonStack.addArrangedSubviews(self.todayRankButton,
                                             self.totalRankButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.buttonStack.topAnchor.constraint(equalTo: self.topAnchor),
            self.buttonStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.buttonStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.buttonStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.indicatorBar.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.indicatorBar.heightAnchor.constraint(equalToConstant: 1)
        ])
        self.indicatorLeading = indicatorBar.leadingAnchor.constraint(equalTo: self.todayRankButton.leadingAnchor)
        self.indicatorTrailing = indicatorBar.trailingAnchor.constraint(equalTo: self.todayRankButton.trailingAnchor)
        
        self.indicatorLeading?.isActive = true
        self.indicatorTrailing?.isActive = true
    }
}

// MARK: - Indicator Bar
extension RankingMenuBar {
    func selectItem(at index: Int) {
        animateIndicator(to: index)
    }
    
    private func animateIndicator(to index: Int) {
        var button: UIButton
        switch index {
        case 0:
            button = todayRankButton
        default:
            button = totalRankButton
        }

        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    func scrollIndicator(to contentOffset: CGPoint) {
        let index = Int(contentOffset.x / frame.width)
        let atScrollStart = Int(contentOffset.x) % Int(frame.width) == 0
        
        if atScrollStart {
            return
        }
        
        let percentScrolled: CGFloat
        switch index {
        case 1:
            percentScrolled = contentOffset.x / frame.width - 1
        default:
            percentScrolled = contentOffset.x / frame.width
        }
        
        // Determine buttons
        var fromButton: UIButton
        var toButton: UIButton
        
        switch index {
        case 1:
            fromButton = buttons[index]
            toButton = buttons[index - 1]
        default:
            fromButton = buttons[index]
            toButton = buttons[index + 1]
        }
        
        // Animate alpha of buttons
        switch index {
        default:
            fromButton.alpha = fmax(0.5, (1 - percentScrolled))
            toButton.alpha = fmax(0.5, percentScrolled)
        }
        
        // Determine width
        let fromWidth = fromButton.frame.width
        let toWidth = toButton.frame.width
        let sectionWidth: CGFloat
        switch index {
        case 0:
            sectionWidth = leadPadding + fromWidth + buttonSpace
        default:
            sectionWidth = fromWidth + buttonSpace
        }
        
        // Normalize x scroll
        let sectionFraction = sectionWidth / frame.width
        let x = contentOffset.x * sectionFraction
        
        let buttonWidthDiff = fromWidth - toWidth
        let widthOffset = buttonWidthDiff * percentScrolled
        
        let y: CGFloat
        switch index {
        case 0:
            if x < leadPadding {
                y = x
            } else {
                y = x - (leadPadding * percentScrolled)
            }
        default:
            y = x
        }
        
        indicatorLeading?.constant = y
        
        let yTrailing: CGFloat
        switch index {
        case 0:
            yTrailing = y - widthOffset
        default:
            yTrailing = y - widthOffset - leadPadding
        }
        
        indicatorTrailing?.constant = yTrailing
        /// for debug
//        print("\(index) percentScrolled = \(percentScrolled)")
    }
}
