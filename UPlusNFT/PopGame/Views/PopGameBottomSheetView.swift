//
//  PopGameBottomSheetView.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/20.
//

import UIKit
import Combine
import DifferenceKit
import Nuke

enum SectionID: Differentiable {
    case first, second
}

final class PopGameBottomSheetView: PassThroughView {
    
    let prefetcher = ImagePrefetcher()
    let bottomSheetVM: PopGameBottomSheetViewModel
    
    var currentUserScoreUpdateHandler: ((Int64) -> Void)?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    
    // MARK: - UI Elements
    
    let bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let barView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let leaderBoardStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 15
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let leaderBoardLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: LeaderBoardAsset.markImageName.rawValue)
        return imageView
    }()
    
    private let leaderBoardLabel: UILabel = {
        let label = UILabel()
        label.font = BellyGomFont.header03
        label.textColor = .white
        label.text = LeaderBoardAsset.title.rawValue
        return label
    }()
    
    let leaderBoardTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = AftermintColor.backgroundNavy
        
        table.alpha = 0.0
        table.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        table.register(LeaderBoardFirstSectionCell.self, forCellReuseIdentifier: LeaderBoardFirstSectionCell.identifier)
        table.register(LeaderBoardSecondSectionCell.self, forCellReuseIdentifier: LeaderBoardSecondSectionCell.identifier)
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10.0, right: 0)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Properties
    var mode: Mode = .tip {
        didSet {
            switch self.mode {
            case .tip:
                break
            case .full:
                break
            }
            self.updateConstraint(offset: Const.bottomSheetYPosition(self.mode))
        }
    }
    
    var bottomSheetColor: UIColor? {
        didSet { self.bottomSheetView.backgroundColor = self.bottomSheetColor }
    }
    
    var barViewColor: UIColor? {
        didSet { self.barView.backgroundColor = self.barViewColor }
    }
    
    // MARK: - Initializer
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init() has not been implemented")
    }
    
    init(
        frame: CGRect,
        bottomSheetVM: PopGameBottomSheetViewModel
    ) {
        self.bottomSheetVM = bottomSheetVM
        super.init(frame: frame)

        self.backgroundColor = .clear
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        self.addGestureRecognizer(panGesture)
        
        self.bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.bottomSheetView.layer.cornerRadius = Const.cornerRadius
        self.bottomSheetView.clipsToBounds = true
        
        setUI()
        setLayout()
        setDelegate()

        self.bottomSheetVM.getInitialItems(of: .uplus, gameType: .popgame)
        bind()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = self.barView.frame.size.height
        self.barView.layer.cornerRadius = height / 2
    }
    
    // MARK: - SetUI & Layout
    /// Dynamic BottomSheet top constraint
    var bottomSheetViewTopConstraint: NSLayoutConstraint?
    
    private func setUI() {
        
        self.addSubview(self.bottomSheetView)
        self.bottomSheetView.addSubview(self.barView)
        self.bottomSheetView.addSubview(leaderBoardStackView)
        self.bottomSheetView.addSubview(leaderBoardTableView)
        self.leaderBoardStackView.addArrangedSubview(leaderBoardLogoImageView)
        self.leaderBoardStackView.addArrangedSubview(leaderBoardLabel)
        
        leaderBoardTableView.separatorColor = AftermintColor.separatorNavy
    }
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            self.bottomSheetView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.bottomSheetView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.bottomSheetView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.barView.topAnchor.constraint(equalTo: self.bottomSheetView.topAnchor, constant: Const.barViewTopSpacing),
            self.barView.widthAnchor.constraint(equalToConstant: Const.barViewWidth),
            self.barView.heightAnchor.constraint(equalToConstant: Const.barViewHeight),
            self.barView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.leaderBoardStackView.topAnchor.constraint(equalToSystemSpacingBelow: barView.bottomAnchor, multiplier: 2),
            self.leaderBoardStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.leaderBoardTableView.topAnchor.constraint(equalToSystemSpacingBelow: self.leaderBoardStackView.bottomAnchor, multiplier: 2),
            self.leaderBoardTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.leaderBoardTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.leaderBoardTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        bottomSheetViewTopConstraint = self.bottomSheetView.topAnchor.constraint(equalTo: self.topAnchor, constant: Const.bottomSheetYPosition(.tip))
        bottomSheetViewTopConstraint?.isActive = true
        
    }
    
    // MARK: Methods
    @objc private func didPan(_ recognizer: UIPanGestureRecognizer) {
        
        let translationY = recognizer.translation(in: self).y
        let minY = self.bottomSheetView.frame.minY
        let offset = translationY + minY
        
        if Const.bottomSheetYPosition(.full)...Const.bottomSheetYPosition(.tip) ~= offset {
            self.updateConstraint(offset: offset)
            recognizer.setTranslation(.zero, in: self)
        }
        
        UIView.animate(
            withDuration: 0,
            delay: 0,
            options: .curveEaseOut,
            animations: self.layoutIfNeeded,
            completion: nil
        )
        
        guard recognizer.state == .ended else { return }
        UIView.animate(
            withDuration: Const.duration,
            delay: 0,
            options: .allowUserInteraction,
            animations: {
                self.mode = recognizer.velocity(in: self).y >= 0 ? Mode.tip : .full
            },
            completion: nil
        )
    }
    
    /// Update top constraint of the bottom sheet by pan gesture offset
    private func updateConstraint(offset: Double) {
        bottomSheetViewTopConstraint?.constant = offset
        self.layoutIfNeeded()
    }
    
    private func bind() {

        self.bottomSheetVM.$changeset
            .receive(on: DispatchQueue.main)
            .sink { [weak self] vms in
                guard let `self` = self else { return }
                
                var hasChanges: Bool = false

                var changes: Set<IndexPath> = []

                var arrSections: [ArraySection<SectionID, AnyDifferentiable>] = []
                for vm in vms {

    //                print("updated vm: \(vm.elementUpdated)")
    //                print("inserted vm: \(vm.elementInserted)")
    //                print("deleted vm: \(vm.elementDeleted)")
    //                print("Moved vm: \(vm.elementMoved)")

                    for data in vm.data {
                        arrSections.append(ArraySection(model: data.model, elements: data.elements))
                    }
                    let elementsMoved = vm.elementMoved

                    for ele in elementsMoved {
                        let sourceEle = ele.source.element
                        let sourceSec = ele.source.section

                        let targetEle = ele.target.element
                        let targetSec = ele.target.section

                        changes.insert(IndexPath(row: sourceEle, section: sourceSec))
                        changes.insert(IndexPath(row: targetEle, section: targetSec))
                    }
    //                print("Orginals: \(original)")
    //                print("News: \(new)")

                    if vm.hasElementChanges {
                        hasChanges = true
                    }
                    
                }

                if hasChanges {
                    DispatchQueue.main.async {
                        self.leaderBoardTableView.alpha = 1.0

                        self.leaderBoardTableView.reload(
                            using: vms,
                            deleteSectionsAnimation: .none,
                            insertSectionsAnimation: .none,
                            reloadSectionsAnimation: .none,
                            deleteRowsAnimation: .fade,
                            insertRowsAnimation: .bottom,
                            reloadRowsAnimation: .middle,
                            setData: { coll in
                                self.bottomSheetVM.source = coll
                            }
                        )
                        
                        self.leaderBoardTableView.reloadRows(at: Array(changes), with: .middle)
                         
                    }
                    hasChanges = false
                }
                
            }
            .store(in: &bindings)
 
    }
    
}

// MARK: - TableView Delegate & DataSource
extension PopGameBottomSheetView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            guard let numberOfRows = self.bottomSheetVM.source.first?.elements.count else { return 0 }
            return numberOfRows
        } else {
            guard let numberOfRows = self.bottomSheetVM.source.last?.elements.count else { return 0 }
            return numberOfRows
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        do {
            let user = try UPlusUser.getCurrentUser()
            
            if indexPath.section == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: LeaderBoardFirstSectionCell.identifier) as? LeaderBoardFirstSectionCell else { return UITableViewCell() }
                cell.selectionStyle = .none
                cell.resetCell()
             
                guard let vm = bottomSheetVM.firstListVM.modelAt(indexPath) else {
                    return UITableViewCell()
                }
                
                cell.configure(with: vm)
                return cell
                
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: LeaderBoardSecondSectionCell.identifier) as? LeaderBoardSecondSectionCell,
                      let vm = self.bottomSheetVM.secondListVM.modelAt(indexPath)
                else { return UITableViewCell() }
                cell.selectionStyle = .none
                cell.resetCell()
        
                if vm.ownerAddress == user.userWalletAddress ?? "" {
                    cell.contentView.backgroundColor = .systemPurple.withAlphaComponent(0.2)
                    self.currentUserScoreUpdateHandler = { count in
                        cell.popScoreLabel.text = "\(count)"
                    }
                }

                //TODO: Make below logic as a separate function
                if indexPath.row <= 2 {
                    vm.setRankImage(with: cellRankImageAt(indexPath.row))
                } else {
                    cell.switchRankImageToLabel()
                    vm.setRankNumberWithIndexPath(indexPath.row + 1)
                }

                cell.configure(with: vm)
                return cell
            }
        }
        catch {
            return UITableViewCell()
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        } else {
            return 50
        }
    }
    
    /// Determine cell image
    private func cellRankImageAt(_ indexPathRow: Int) -> UIImage? {
        switch indexPathRow {
        case 0:
            return UIImage(named: ImageAssets.goldTrophy)
        case 1:
            return UIImage(named: ImageAssets.silverTrophy)
        case 2:
            return UIImage(named: ImageAssets.bronzeTrophy)
        default:
            return UIImage(named: ImageAssets.bronzeTrophy)
        }
    }
    
    private func setDelegate() {
        leaderBoardTableView.delegate = self
        leaderBoardTableView.dataSource = self
        leaderBoardTableView.prefetchDataSource = self
    }
    
    
    
}

extension PopGameBottomSheetView: UITableViewDataSourcePrefetching {
    
    /// PretchImageAt
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urlStrings: [String] = indexPaths.compactMap {
            self.bottomSheetVM.secondListVM.modelAt($0)?.userProfileImage
        }
        let urls: [URL] = urlStrings.compactMap {
            URL(string: $0)
        }
        prefetcher.startPrefetching(with: urls)
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        let urlStrings: [String] = indexPaths.compactMap {
            self.bottomSheetVM.secondListVM.modelAt($0)?.userProfileImage
        }
        let urls: [URL] = urlStrings.compactMap {
            URL(string: $0)
        }
        prefetcher.stopPrefetching(with: urls)
    }

}

// MARK: - Enums
extension PopGameBottomSheetView {
    // MARK: Constants
    enum Mode {
        case tip
        case full
    }
    
    private enum Const {
        static let duration = 0.0
        static let cornerRadius = 12.0
        static let barViewTopSpacing = 5.0
        static let barViewWidth = UIScreen.main.bounds.width * 0.2
        static let barViewHeight = 5.0
        static let bottomSheetRatio: (Mode) -> Double = { mode in
            switch mode {
            case .tip:
                return 0.47 // 위에서 부터의 값 (밑으로 갈수록 값이 커짐)
            case .full:
                return 0.1
            }
        }
        static let bottomSheetYPosition: (Mode) -> Double = { mode in
            Self.bottomSheetRatio(mode) * UIScreen.main.bounds.height
        }
    }
}

