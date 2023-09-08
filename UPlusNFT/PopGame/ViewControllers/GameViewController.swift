//
//  GameViewController.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/09.
//

import UIKit
import Combine
import Nuke
import SpriteKit

final class GameViewController: UIViewController {
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - Constants
    private var nickNameLabelText: String = ""
    private var initialTouchScore: Int = 0
    
    // MARK: - Dependency
    private var bottomSheetVM: PopGameBottomSheetViewModel
    private var gameVM: GameViewViewModel
    private var scene: PopGameScene?
    
    //MARK: - Game score data variables
    var timer: Timer = Timer()
    
    /// Pop score retrieve from db.
    var popScoreFromDB: Int64 = 0
    /// Action count retrieve from db.
    var actionCountFromDB: Int64 = 0
    
    /// Touch counts before send set query to db.
    /// Will be reset to `0` after saved to db.
    private var touchCount: Int64 = 0
    /// Reset when resume game.
    private var totalTouchCount: Int64 = 0
    /// Stays until app termination
    private var touchCountToShow: Int64 = 0 {
        didSet {
            self.popScoreLabel.text = "\(self.touchCountToShow)"
        }
    }
    
    private var numberOfOwnedNfts: Int64 = 0
    
    // MARK: - UI Elements
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = AftermintColor.backgroundNavy.withAlphaComponent(PopGameConstants.alpha)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let userInfoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let walletAddressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = " "
        label.font = BellyGomFont.header08
        label.backgroundColor = AftermintColor.backgroundNavy.withAlphaComponent(PopGameConstants.alpha)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = self.nickNameLabelText
        label.textColor = .white
        label.text = " "
        label.backgroundColor = AftermintColor.backgroundNavy.withAlphaComponent(PopGameConstants.alpha)
        label.font = BellyGomFont.header04
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let popRankStack: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelText = "Pop Rank"
        stack.topLabelFont = BellyGomFont.header05
        stack.topLabelTextColor = AftermintColor.bellyGreen
        stack.bottomLabelFont = BellyGomFont.header09
        stack.bottomLabelBackgroundColor = AftermintColor.backgroundNavy.withAlphaComponent(PopGameConstants.alpha)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let popScoreStack: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelText = "Pop Score"
        stack.topLabelFont = BellyGomFont.header05
        stack.topLabelTextColor = AftermintColor.bellyGreen
        stack.bottomLabelFont = BellyGomFont.header09
        stack.bottomLabelBackgroundColor = AftermintColor.backgroundNavy.withAlphaComponent(PopGameConstants.alpha)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nftsStack: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelText = "NFTs"
        stack.topLabelFont = BellyGomFont.header05
        stack.topLabelTextColor = AftermintColor.bellyGreen
        stack.bottomLabelFont = BellyGomFont.header05
        stack.bottomLabelBackgroundColor = AftermintColor.backgroundNavy.withAlphaComponent(PopGameConstants.alpha)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let actionCountStack: VerticalDoubleStackView = {
        let stack = VerticalDoubleStackView()
        stack.topLabelText = "Action Count"
        stack.topLabelFont = BellyGomFont.header05
        stack.topLabelTextColor = AftermintColor.bellyGreen
        stack.bottomLabelFont = BellyGomFont.header05
        stack.bottomLabelBackgroundColor = AftermintColor.backgroundNavy.withAlphaComponent(PopGameConstants.alpha)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    //Change this to Pop Score Label
    private lazy var popScoreLabel: UILabel = {
        let label = UILabel()
        label.text = "\(self.initialTouchScore)"
        label.textColor = .white
        label.font = BellyGomFont.header03
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var gameSKView: SKView = {
        let view = SKView()
        view.backgroundColor = AftermintColor.secondaryBackgroundNavy
        view.showsFPS = false
        view.showsNodeCount = false
        view.ignoresSiblingOrder = true
        return view
    }()
    
    private lazy var bottomSheetView: PopGameBottomSheetView = {
        let bottomSheet = PopGameBottomSheetView(
            frame: .zero,
            bottomSheetVM: bottomSheetVM
        )
        bottomSheet.bottomSheetColor = AftermintColor.backgroundNavy
        bottomSheet.barViewColor = .darkGray
        bottomSheet.translatesAutoresizingMaskIntoConstraints = false
        return bottomSheet
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    // MARK: - Init
    init(gameVM: GameViewViewModel,
         bottomSheetVM: PopGameBottomSheetViewModel) {
        self.gameVM = gameVM
        self.bottomSheetVM = bottomSheetVM
        super.init(nibName: nil, bundle: nil)
        self.spinner.startAnimating()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = PopGameConstants.popgame
        
        setUI()
        setLayout()
        setGameScene()
        setDelegate()
        
        gameVM.getOwnedNfts()
        bind()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationBarSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        saveAndRetrieveGameCache(after: 5.0)
        
        if self.navigationController?.isNavigationBarHidden ?? true {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    override func viewWillLayoutSubviews() {
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ///Disable the timer when the view disappeared
        timer.invalidate()
        saveGameTotalScore()
    }
    
    private func navigationBarSetup() {
     
//        let logo = UIImage(named: GameAsset.gameVCLogo.rawValue)
//        let myImageView = UIImageView(image: logo)
//        let leftBar: UIBarButtonItem = UIBarButtonItem(customView: myImageView)
//        self.tabBarController?.navigationItem.leftBarButtonItem = leftBar
//        self.tabBarController?.navigationItem.rightBarButtonItems = nil
    }
    
    // MARK: - Set UI & Layout
    
    private func setDelegate() {
        self.bottomSheetVM.secondListVM.delegate = self
    }
    
    private func setUI() {
        view.backgroundColor = AftermintColor.backgroundLightBlue
        view.addSubview(gameSKView)
        view.addSubview(userImageView)
        view.addSubview(userInfoStackView)
        view.addSubview(bottomSheetView)
        view.addSubview(popRankStack)
        view.addSubview(popScoreStack)
        view.addSubview(nftsStack)
        view.addSubview(actionCountStack)
        view.addSubview(spinner)
        
        userInfoStackView.addArrangedSubview(walletAddressLabel)
        userInfoStackView.addArrangedSubview(nickNameLabel)
    }
    
    private func setLayout() {
        let viewHeight = view.frame.size.height
        gameSKView.frame = view.bounds
        let spinnerHeight: CGFloat = 50
        
        NSLayoutConstraint.activate([
            self.userImageView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.userImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            self.userImageView.heightAnchor.constraint(equalToConstant: viewHeight / 14),
            self.userImageView.widthAnchor.constraint(equalTo: self.userImageView.heightAnchor),
            
            self.userInfoStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.userImageView.trailingAnchor, multiplier: 1),
            self.userInfoStackView.centerYAnchor.constraint(equalTo: self.userImageView.centerYAnchor),
            
            self.popRankStack.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 0),
            self.popRankStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.userInfoStackView.trailingAnchor, multiplier: 1),
            self.popScoreStack.topAnchor.constraint(equalTo: self.popRankStack.topAnchor),
            self.popScoreStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.popRankStack.trailingAnchor, multiplier: 1),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.popScoreStack.trailingAnchor, multiplier: 1),
            
            self.nftsStack.topAnchor.constraint(equalToSystemSpacingBelow: self.popRankStack.bottomAnchor, multiplier: 1),
            self.nftsStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.userInfoStackView.trailingAnchor, multiplier: 1),
            self.actionCountStack.topAnchor.constraint(equalTo: self.nftsStack.topAnchor),
            self.actionCountStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.nftsStack.trailingAnchor, multiplier: 1),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.actionCountStack.trailingAnchor, multiplier: 1),
            
            
            self.bottomSheetView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.bottomSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.bottomSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            self.spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.spinner.heightAnchor.constraint(equalToConstant: spinnerHeight),
            self.spinner.widthAnchor.constraint(equalTo: spinner.heightAnchor)
        ])
    }
    
    //MARK: - Private
    
    private func bind() {
        
        #if DEBUG
        self.gameVM.$ownedNftTokenIds
            .sink {
                print("OwnedNftTokenIds: \($0)")
            }
            .store(in: &bindings)
        #endif
        
        self.bottomSheetVM.$isLoaded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoaded in
                guard let `self` = self else { return }
                
                if isLoaded {
                    print("Is loaded!")
                    self.spinner.stopAnimating()
                }
            }
            .store(in: &bindings)
    }
    
    private func saveGameTotalScore() {
        
        do {
            let user = try UPlusUser.getCurrentUser()
            
            Task {
                try await self.gameVM.saveScoreCache(
                    of: .popgame,
                    popScore: self.touchCount * self.numberOfOwnedNfts,
                    actionCount: self.touchCount,
                    ownerAddress: user.userWalletAddress ?? ""
                )
                print("Touch count saved to cache: \(self.touchCount)")
                self.touchCount = 0
            }
            
            Task {
                try await self.gameVM.saveNFTScores(
                    of: .popgame,
                    actionCount: self.totalTouchCount,
                    nftTokenId: self.gameVM.ownedNftTokenIds,
                    ownerAddress: user.userWalletAddress ?? "no-wallet"
                )
                print("Total touch count saved to each nft: \(self.totalTouchCount)")
                self.totalTouchCount = 0
            }
        }
        catch {
            UPlusLogger.logger.error("Error saving game total score -- \(String(describing: error))")
        }
        
    }
    
    private func saveAndRetrieveGameCache(after second: TimeInterval) {
        do {
            let user = try UPlusUser.getCurrentUser()
            timer = Timer.scheduledTimer(
                withTimeInterval: second,
                repeats: true,
                block: { [weak self] _ in
                    guard let `self` = self else { return }
                    // Save game score to db
                    Task {
                        try await self.gameVM.saveScoreCache(
                            of: .popgame,
                            popScore: self.touchCount * self.numberOfOwnedNfts,
                            actionCount: self.touchCount,
                            ownerAddress: user.userWalletAddress ?? "no-wallet"
                        )
                        print("Touch saved: \(self.touchCount)")
                        self.touchCount = 0
                        
                        // Retrive game score from db
//                        try await self.bottomSheetVM.getCachedItems(of: .uplus, gameType: .popgame)
                    }
                    
                })
        }
        catch {
            UPlusLogger.logger.error("Error save and retrieve game cached data from firestore -- \(String(describing: error))")
        }
        
    }
    
}

// MARK: - Set GameScene
extension GameViewController {
    
    private func setGameScene() {
        let width = view.frame.size.width
        let height = view.frame.size.height
        scene = PopGameScene(size: CGSize(width: width, height: height))
        guard let scene = scene else { return }
        scene.gameSceneDelegate = self
        scene.backgroundColor = UIColor(red: 34/255, green: 26/255, blue: 80/255, alpha: 0.8)
        scene.scaleMode = .aspectFit
        gameSKView.presentScene(scene)
    }

}

extension GameViewController: PopGameSceneDelegate {
    
    func didReceiveTouchCount(number: Int64) {
        
        self.touchCountToShow += number
        self.totalTouchCount += number
        self.touchCount += number
        
        self.popScoreFromDB += (number * self.numberOfOwnedNfts)
        self.actionCountFromDB += number
        
        self.popScoreStack.bottomLabelText = "\(self.popScoreFromDB)"
        self.actionCountStack.bottomLabelText = "\(self.actionCountFromDB)"
        
        self.bottomSheetView.currentUserScoreUpdateHandler?(self.popScoreFromDB)
        
    }

}

// TODO: NO4. BottomSheetVMDelegate으로 이동
extension GameViewController: LeaderBoardSecondSectionCellListViewModelDelegate {
    func currentUserDataFetched(_ vm: LeaderBoardSecondSectionCellViewModel) {
        
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) { [weak self] in
                
                guard let `self` = self else { return }
                
                self.numberOfOwnedNfts = Int64(vm.numberOfNfts) ?? 0
                self.walletAddressLabel.backgroundColor = .clear
                self.nickNameLabel.backgroundColor = .clear
                self.popScoreStack.bottomLabelBackgroundColor = .clear
                self.popRankStack.bottomLabelBackgroundColor = .clear
                self.nftsStack.bottomLabelBackgroundColor = .clear
                self.actionCountStack.bottomLabelBackgroundColor = .clear
                self.userImageView.layer.borderColor = UIColor(ciColor: .white).cgColor
                self.userImageView.layer.borderWidth = 1.0
  
                self.walletAddressLabel.text = vm.ownerAddress.cutOfRange(length: 10)
                self.nickNameLabel.text = "NFTs \(vm.numberOfNfts.count)"
                
                /// Scoreboard part
                self.nftsStack.bottomLabelText = vm.numberOfNfts
                self.popRankStack.bottomLabelText = "12" // TODO: TEMPORARY VALUE
                self.popScoreFromDB = vm.popScore
                self.actionCountFromDB = vm.actionCount
                self.popScoreStack.bottomLabelText = String(describing: self.popScoreFromDB)
                self.actionCountStack.bottomLabelText = String(describing: self.actionCountFromDB)
                
                /// User information part
                guard let url = URL(string: vm.userProfileImage) else {
                    self.userImageView.image = UIImage(named: ImageAssets.profileDefault)
                    return
                }
                
                ImagePipeline.shared.loadImage(with: url) { result in
                    switch result {
                    case .success(let success):
                        self.userImageView.image = success.image
                    case .failure(_):
                        self.userImageView.image = UIImage(named: ImageAssets.profileDefault)
                    }
                }
            }
        }
    }
    
    func differentFunction() {
        print("Different delegate function.")
    }
}
