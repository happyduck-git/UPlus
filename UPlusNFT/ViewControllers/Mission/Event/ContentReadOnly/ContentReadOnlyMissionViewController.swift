//
//  ContentReadOnlyMissionViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import UIKit
import Combine
import Nuke

//protocol ContentReadOnlyMissionViewControllerDelegate: AnyObject {
//    func redeemDidTap()
//}

final class ContentReadOnlyMissionViewController: BaseMissionScrollViewController {

    enum ReadOnlyMissionType {
        case weekly
        case event
    }
    
    private let type: ReadOnlyMissionType
    
    //MARK: - Dependency
    private let vm: ContentReadOnlyMissionViewViewModel
    
    //MARK: - Delegate
//    weak var delegate: ContentReadOnlyMissionViewControllerDelegate?
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .equalSpacing
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var images: [UIImage] = []
    
    //MARK: - Init
    init(vm: ContentReadOnlyMissionViewViewModel, type: ReadOnlyMissionType) {
        self.vm = vm
        self.type = type
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.setUI()
        self.setLayout()
        
        self.configure()
        self.bind()
    }

}

extension ContentReadOnlyMissionViewController {
    
    private func configure() {
        self.titleLabel.text = self.vm.mission.missionContentTitle
        self.subTitleLabel.text = self.vm.mission.missionContentText
        self.checkAnswerButton.setTitle(MissionConstants.readCompleted, for: .normal)
    }
    
    private func bind() {
        
        self.vm.$imageUrls
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imagePaths in
                guard let `self` = self else { return }
                self.createImageViews(imagePaths)
            }
            .store(in: &bindings)

        self.checkAnswerButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
    
                switch self.type {
                case .weekly:
                    let vc = WeeklyMissionCompleteViewController(vm: self.vm)
                    vc.delegate = self
                    
                    self.show(vc, sender: self)
                    
                case .event:
                    let vm = EventBaseModel(mission: self.vm.mission)
                    let vc = EventCompletedViewController(vm: vm)
                    vc.delegate = self
                    
                    self.show(vc, sender: self)
                }

            }
            .store(in: &bindings)
        
    }
    
}

//MARK: - Set UI & Layout
extension ContentReadOnlyMissionViewController {
    private func setUI() {
        self.containerView.addSubview(self.stack)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.stack.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.stack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.stack.trailingAnchor, multiplier: 2),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.stack.bottomAnchor, multiplier: 5)
        ])
    }
    
    private func createImageViews(_ urls: [URL]) {
        Task {
            do {
                for i in 0..<urls.count {
                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFit
                    imageView.frame.size = CGSize(width: self.stack.frame.width, height: self.view.frame.size.height / 4)
                    imageView.image = try await ImagePipeline.shared.image(for: urls[i])
                    self.stack.addArrangedSubview(imageView)
                }
            }
            catch {
                print("Error fetching image -- \(error)")
            }
        }
    }
}

extension ContentReadOnlyMissionViewController: WeeklyMissionCompleteViewControllerDelegate, EventCompletedViewControllerDelegate {
    
    func redeemDidTap() {
        self.delegate?.redeemDidTap(vc: self)
    }
    
}

