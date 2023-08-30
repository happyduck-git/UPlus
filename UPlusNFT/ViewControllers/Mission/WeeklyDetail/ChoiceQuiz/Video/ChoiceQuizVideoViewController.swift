//
//  ChoiceQuizViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import UIKit
import WebKit
import Combine

final class ChoiceQuizVideoViewController: BaseMissionViewController {

    //MARK: - Dependency
    private let vm: ChoiceQuizVideoViewViewModel
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    
    // Video Watch View
    private let videoContainerView: UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let videoPlayer: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.backgroundColor = .systemGray4
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isUserInteractionEnabled = false
        return webView
    }()
    
    private let videoDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UPlusColor.mint05
        label.font = .systemFont(ofSize: UPlusFont.body2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Choice View
    private let choiceContainerView: UIView = {
       let view = UIView()
        view.isHidden = true
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let buttonStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 5.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var stacks: [UIStackView] = []
    private var buttons: [ChoiceMultipleQuizButton] = []
    
    //MARK: - Init
    init(vm: ChoiceQuizVideoViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        self.setBaseVM(vm: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.createButtons()
        self.setUI()
        self.setLayout()
        self.configure()
        self.bind()
        
        self.playYTVideo()
    }
   
}

//MARK: - Create Buttons
extension ChoiceQuizVideoViewController {
    private func createButtons() {
        guard let mission = self.vm.mission as? ChoiceQuizMission else { return }
        let captions = mission.missionChoiceQuizCaptions
        var numberOfCaptions = captions.count
        if numberOfCaptions % 2 != 0 {
            numberOfCaptions += 1
        }
        
        for i in 0..<numberOfCaptions/2 {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.distribution = .fillEqually
            stack.spacing = 8.0
            self.stacks.append(stack)
            
            for j in 0+i..<2+i {
                let order = i+j
                let button = ChoiceMultipleQuizButton()
                button.tag = order
                button.clipsToBounds = true
                button.layer.cornerRadius = 8.0
                button.backgroundColor = .white
                button.layer.borderWidth = 2.0
                button.layer.borderColor = UIColor.clear.cgColor
                
                if order < captions.count {
                    button.setQuizTitle(text: mission.missionChoiceQuizCaptions[order])
                }
                
                self.buttons.append(button)
                stack.addArrangedSubview(button)
            }
        }
        
        self.vm.buttonStatus = Array(repeating: false, count: captions.count)
    }
}

//MARK: - Set UI & Layout
extension ChoiceQuizVideoViewController {
    private func setUI() {
        self.quizContainer.addSubviews(self.videoContainerView,
                                       self.choiceContainerView)
        
        self.videoContainerView.addSubviews(self.videoPlayer,
                                            self.videoDescriptionLabel)
        
        self.choiceContainerView.addSubviews(self.buttonStack)
        
        for i in 0..<self.stacks.count {
            self.buttonStack.addArrangedSubview(self.stacks[i])
        }
    }
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            self.videoContainerView.topAnchor.constraint(equalTo: self.quizContainer.topAnchor),
            self.videoContainerView.leadingAnchor.constraint(equalTo: self.quizContainer.leadingAnchor),
            self.videoContainerView.trailingAnchor.constraint(equalTo: self.quizContainer.trailingAnchor),
            self.videoContainerView.bottomAnchor.constraint(equalTo: self.quizContainer.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.videoPlayer.topAnchor.constraint(equalToSystemSpacingBelow: self.videoContainerView.topAnchor, multiplier: 1),
            self.videoPlayer.leadingAnchor.constraint(equalToSystemSpacingAfter: self.videoContainerView.leadingAnchor, multiplier: 1),
            self.videoContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.videoPlayer.trailingAnchor, multiplier: 1),
            self.videoPlayer.heightAnchor.constraint(equalToConstant: self.view.frame.height / 3.5),
            
            self.videoDescriptionLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.videoPlayer.bottomAnchor, multiplier: 1),
            self.videoDescriptionLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.videoContainerView.leadingAnchor, multiplier: 2),
            self.videoContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.videoDescriptionLabel.trailingAnchor, multiplier: 2),
//            self.videoContainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.videoDescriptionLabel.bottomAnchor, multiplier: 1)
        ])

        NSLayoutConstraint.activate([
            self.choiceContainerView.topAnchor.constraint(equalToSystemSpacingBelow: self.quizContainer.topAnchor, multiplier: 4),
            self.choiceContainerView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizContainer.leadingAnchor, multiplier: 5),
            self.quizContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.choiceContainerView.trailingAnchor, multiplier: 5),
            self.quizContainer.bottomAnchor.constraint(equalToSystemSpacingBelow: self.choiceContainerView.bottomAnchor, multiplier: 4),
            
            self.buttonStack.topAnchor.constraint(equalToSystemSpacingBelow: self.choiceContainerView.topAnchor, multiplier: 1),
            self.buttonStack.leadingAnchor.constraint(equalTo: self.choiceContainerView.leadingAnchor),
            self.buttonStack.trailingAnchor.constraint(equalTo: self.choiceContainerView.trailingAnchor),
            self.choiceContainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.buttonStack.bottomAnchor, multiplier: 1)
        ])
      
    }
}

extension ChoiceQuizVideoViewController {
    private func configure() {

        if vm.mission.missionSubFormatType == MissionSubFormatType.choiceQuizVideo.rawValue {
            let map = vm.mission.missionContentExtraMap ?? [:]
            let frontTop = map[FirestoreConstants.videoQuizFrontTopText] ?? ""
            let frontBottom = map[FirestoreConstants.videoQuizFrontBottomText] ?? ""
            let rearTop = map[FirestoreConstants.videoQuizRearTopText] ?? ""
            
            self.vm.frontBottom = frontBottom
            self.vm.rearTop = rearTop
            
            if let attributedString = vm.retrieveHtmlString(html: frontTop) {
                self.weblinkButton.isHidden = false
                weblinkButton.setAttributedTitle(attributedString, for: .normal)
            }
            
            if let attributedString = vm.retrieveHtmlString(html: self.vm.frontBottom) {
                self.videoDescriptionLabel.attributedText = attributedString
            }

        }
        
        self.checkAnswerButton.isUserInteractionEnabled = true
        self.checkAnswerButton.setTitle(MissionConstants.next, for: .normal)
    }
    
    private func bind() {
        func bindViewToViewModel() {
            self.weblinkButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    if !self.vm.isVideoScreen {
                        if let attributedString = vm.retrieveHtmlString(html: self.vm.rearTop) {
                            self.weblinkButton.setAttributedTitle(attributedString, for: .normal)
                        }
                        self.vm.openURL(from: self.vm.rearTop)
                    }
                    
                }
                .store(in: &bindings)
            
            self.checkAnswerButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    if self.vm.isVideoScreen {
                        self.vm.isVideoScreen.toggle()
                        
                        self.stopVideo()
                        self.videoContainerView.isHidden = true
                        self.choiceContainerView.isHidden = false
                     
                        if let attributedString = vm.retrieveHtmlString(html: self.vm.rearTop) {
                            self.videoDescriptionLabel.attributedText = attributedString
                        }
                        
                        self.checkAnswerButton.setTitle(MissionConstants.checkAnswer, for: .normal)
                        self.toggleButtonActivation(status: false)
                        
                    } else {
                        guard let mission = self.vm.mission as? ChoiceQuizMission,
                              let selectedAnswer = self.vm.selectedButton
                        else { return }
                        
                        if mission.missionChoiceQuizRightOrder == selectedAnswer {
                            self.vm.isRightAnswerSubmitted.send(true)
                            
                        } else {
                            self.vm.isRightAnswerSubmitted.send(false)
                        }
                    }
     
                }
                .store(in: &bindings)
            
            for button in buttons {
                button.tapPublisher
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] _ in
                        guard let `self` = self else { return }
                        
                        self.answerInfoLabel.isHidden = true
                        self.toggleButtonActivation(status: true)
                        
                        let tag = button.tag
                        if !self.vm.buttonStatus[tag] {
                            if let prev = self.vm.selectedButton {
                                self.vm.buttonStatus[prev].toggle()
                                self.buttons[prev].layer.borderColor = UIColor.clear.cgColor
                                self.buttons[prev].toggleImage(hidden: true)
                            }
                            self.buttons[tag].layer.borderColor = UPlusColor.mint03.cgColor
                            
                            self.vm.buttonStatus[tag].toggle()
                            self.buttons[tag].toggleImage(hidden: false)
                            self.vm.selectedButton = tag
                        }
                    }
                    .store(in: &bindings)
            }
        }
        
        func bindViewModelToView() {
            self.vm.$isActivated
                .receive(on: DispatchQueue.main)
                .sink { [weak self] activated in
                    guard let `self` = self else { return }
                    
                    self.toggleButtonActivation(status: activated)

                }
                .store(in: &bindings)
            
            self.vm.isRightAnswerSubmitted
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isRight in
                    guard let `self` = self else { return }
                    
                    if isRight {
                        var vc: BaseMissionCompletedViewController?
                        
                        switch self.vm.type {
                        case .event:
                            vc = EventCompletedViewController(vm: self.vm)
                            vc?.delegate = self
                        case .weekly:
                            vc = WeeklyMissionCompleteViewController(vm: self.vm)
                            vc?.delegate = self
                        }
                        
                        guard let vc = vc else { return }
                        self.navigationController?.modalPresentationStyle = .fullScreen
                        self.show(vc, sender: self)
                        
                    } else {
                        self.answerInfoLabel.isHidden = false
                        let tag = self.vm.selectedButton ?? 0
                        self.buttons[tag].layer.borderColor = UPlusColor.orange01.cgColor
                    }
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }

}

//MARK: - Private
extension ChoiceQuizVideoViewController {
    private func playYTVideo() {

        guard let mission = self.vm.mission as? ChoiceQuizMission,
        let urlString = mission.missionChoiceQuizExtraBundle,
        let videoURL = self.convertToEmbedURL(from: urlString)
        else { return }

        // Play video
        let request = URLRequest(url: videoURL)
        self.videoPlayer.load(request)
       
        // Set button second
        self.checkAnswerButton.setTitle(String(format: "문제 풀러 가기 (%@초 뒤 활성화)", self.vm.secondLeft), for: .normal)
        self.checkAnswerButton.isUserInteractionEnabled = false
        
        self.returnTrueAfterDelay(seconds: self.vm.secondLeft) { finished in
            self.vm.isActivated = finished
        }
    }
    
    private func extractVideoID(from urlString: String) -> String? {
        if let videoIDRange = urlString.range(of: "(?<=v=)[^,]*", options: .regularExpression) {
            let videoID = String(urlString[videoIDRange])
            return videoID
        } else {
            return nil
        }
    }

    private func convertToEmbedURL(from urlString: String) -> URL? {
        let (urlString, sec) = sliceBySemicolon(from: urlString)
        
        guard let url = urlString,
              let secLeft = sec,
              let videoID = self.extractVideoID(from: url) else {
            return nil
        }
        let embedURLString = "https://www.youtube.com/embed/\(videoID)?autoplay=1"
        
        self.vm.secondLeft = secLeft
        
        return URL(string: embedURLString)
    }
    
    func sliceBySemicolon(from string: String) -> (id: String?, sec: String?) {
        let components = string.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: true)
        return components.count > 1 ? (String(components[0]), String(components[1])) : (nil, nil)
    }
    
    private func stopVideo() {
        self.videoPlayer.evaluateJavaScript("document.querySelector('video').stopVideo();", completionHandler: nil)

    }
    
    /// Return after seconds delay.
    /// - Parameters:
    ///   - seconds: seconds to delay.
    ///   - completion: completion handler.
    private func returnTrueAfterDelay(seconds: String, completion: @escaping (Bool) -> Void) {
        guard let time = Double(seconds) else {
            print("Invalid time format")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            completion(true)
        }
    }
    
}

extension ChoiceQuizVideoViewController {
    private func goToUrl(urlString: String) {
        self.vm.openURL(from: urlString)
    }
}

extension ChoiceQuizVideoViewController {
    private func toggleButtonActivation(status: Bool) {
        let bgColor: UIColor = status ? UPlusColor.mint03 : UPlusColor.gray02
        let txtColor: UIColor = status ? UPlusColor.gray08 : .white
        let interactive: Bool = status ? true : false
        
        self.checkAnswerButton.backgroundColor = bgColor
        self.checkAnswerButton.setTitleColor(txtColor, for: .normal)
        self.checkAnswerButton.isUserInteractionEnabled = interactive
    }
}


extension ChoiceQuizVideoViewController: BaseMissionCompletedViewControllerDelegate {
    func redeemDidTap() {
        self.delegate?.redeemDidTap(vc: self)
    }
}
