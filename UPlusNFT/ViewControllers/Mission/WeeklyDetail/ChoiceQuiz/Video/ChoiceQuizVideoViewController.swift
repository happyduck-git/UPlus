//
//  ChoiceQuizViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import UIKit
import WebKit
import Combine

protocol ChoiceQuizVideoViewControllerDelegate: AnyObject {
    func redeemDidTap()
}

final class ChoiceQuizVideoViewController: BaseMissionViewController {

    //MARK: - Dependency
    private let vm: ChoiceQuizVideoViewViewModel
    
    // MARK: - Delegate
    weak var delegate: ChoiceQuizVideoViewControllerDelegate?
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private var isVideoScreen: Bool = true
    
    // Video Watch View
    private let videoPlayer: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.backgroundColor = .systemGray4
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private let videoDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = MissionConstants.watchVideoDescription
        label.textColor = UPlusColor.mint05
        label.font = .systemFont(ofSize: UPlusFont.body2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Choice View
    private let containerView: UIView = {
       let view = UIView()
        view.isHidden = true
        view.backgroundColor = UPlusColor.gray05
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let quizHintText: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.body1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.spacing = 5.0
            self.stacks.append(stack)
            
            for j in 0+i..<2+i {
                let order = i+j
                let button = ChoiceMultipleQuizButton()
                button.tag = order
                button.backgroundColor = .white
                
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
        self.quizContainer.addSubviews(self.videoPlayer,
                                       self.videoDescriptionLabel,
                              self.containerView)
        
        self.containerView.addSubviews(self.quizHintText,
                                       self.buttonStack)
        
        for i in 0..<self.stacks.count {
            self.buttonStack.addArrangedSubview(self.stacks[i])
        }
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.videoPlayer.topAnchor.constraint(equalToSystemSpacingBelow: self.quizContainer.topAnchor, multiplier: 5),
            self.videoPlayer.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizContainer.leadingAnchor, multiplier: 3),
            self.quizContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.videoPlayer.trailingAnchor, multiplier: 3),
            self.videoPlayer.heightAnchor.constraint(equalToConstant: self.view.frame.height / 3.5),
            
            self.videoDescriptionLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.videoPlayer.bottomAnchor, multiplier: 2),
            self.videoDescriptionLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizContainer.leadingAnchor, multiplier: 2),
            self.quizContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.videoDescriptionLabel.trailingAnchor, multiplier: 2)
        ])

        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalToSystemSpacingBelow: self.quizContainer.topAnchor, multiplier: 4),
            self.containerView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizContainer.leadingAnchor, multiplier: 3),
            self.quizContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.trailingAnchor, multiplier: 3),
            self.quizContainer.bottomAnchor.constraint(equalToSystemSpacingBelow: self.containerView.bottomAnchor, multiplier: 4),
            
            self.quizHintText.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 1),
            self.quizHintText.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.quizHintText.trailingAnchor, multiplier: 2),
            
            self.buttonStack.topAnchor.constraint(equalToSystemSpacingBelow: self.quizHintText.bottomAnchor, multiplier: 8),
            self.buttonStack.leadingAnchor.constraint(equalTo: self.quizHintText.leadingAnchor),
            self.buttonStack.trailingAnchor.constraint(equalTo: self.quizHintText.trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.buttonStack.bottomAnchor, multiplier: 5)
        ])
      
    }
}

extension ChoiceQuizVideoViewController {
    private func configure() {
        self.quizLabel.text = MissionConstants.watchVideo
        self.checkAnswerButton.isUserInteractionEnabled = true
        self.checkAnswerButton.setTitle(MissionConstants.next, for: .normal)
    }
    
    private func bind() {
        
        self.vm.$imageUrls
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                
            }
            .store(in: &bindings)
        
        self.checkAnswerButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                if self.isVideoScreen {
                    self.isVideoScreen.toggle()
                    
                    self.stopVideo()
                    self.videoPlayer.isHidden = true
                    self.videoDescriptionLabel.isHidden = true
                    
                    self.containerView.isHidden = false
                    self.checkAnswerButton.setTitle(MissionConstants.checkAnswer, for: .normal)
                    self.checkAnswerButton.isUserInteractionEnabled = false
                    
                    self.quizHintText.text = self.vm.mission.missionContentTitle
                    
                } else {
                    guard let mission = self.vm.mission as? ChoiceQuizMission,
                          let selectedAnswer = self.vm.selectedButton
                    else { return }
                    
                    if mission.missionChoiceQuizRightOrder == selectedAnswer {
                        
                        let vc = WeeklyMissionCompleteViewController(vm: self.vm)
                        vc.delegate = self
                        self.show(vc, sender: self)
                        
                    } else {
                        self.answerInfoLabel.isHidden = false
                    }
                }
                
                
            }
            .store(in: &bindings)
        
        for button in buttons {
            button.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    self.answerInfoLabel.isHidden = true
                    self.checkAnswerButton.isUserInteractionEnabled = true
                    self.checkAnswerButton.backgroundColor = UPlusColor.gray09
                    
                    let tag = button.tag
                    if !self.vm.buttonStatus[tag] {
                        if let prev = self.vm.selectedButton {
                            self.vm.buttonStatus[prev].toggle()
                            self.buttons[prev].layer.borderColor = UIColor.clear.cgColor
                            self.buttons[prev].toggleImage(hidden: true)
                        }
                        self.buttons[tag].layer.borderColor = UPlusColor.gray05.cgColor
                        
                        self.vm.buttonStatus[tag].toggle()
                        self.buttons[tag].toggleImage(hidden: false)
                        self.vm.selectedButton = tag
                    }
                }
                .store(in: &bindings)
        }
    }
}

//MARK: - Private
extension ChoiceQuizVideoViewController {
    private func playYTVideo() {
        
        guard let iframeString = self.vm.mission.missionContentText,
              let videoURL = self.buildYTUrl(iframeString:  iframeString) else { return }
        
        let request = URLRequest(url: videoURL)
        self.videoPlayer.load(request)
    }
    
    private func buildYTUrl(iframeString: String) -> URL? {
        guard let iframeString = self.vm.mission.missionContentText else { return nil }
        let pattern = "src=\"([^\"]+)\""
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(iframeString.startIndex..<iframeString.endIndex, in: iframeString)
        let matches = regex?.matches(in: iframeString, options: [], range: range)

        if let match = matches?.first, let range = Range(match.range(at: 1), in: iframeString) {
            let srcURL = self.appendAutoplayParameter(to: String(iframeString[range]))
            print(srcURL)
            return URL(string: srcURL)
        } else {
            return nil
        }
        
        
    }
    
    private func appendAutoplayParameter(to url: String) -> String {
        var result = url

            if result.contains("?") {
                result += "&autoplay=1"
            } else {
                result += "?autoplay=1"
            }

            if result.contains("?") {
                result += "&enablejsapi=1"
            } else {
                result += "?enablejsapi=1"
            }
            
            return result
    }
    
    private func stopVideo() {
        self.videoPlayer.evaluateJavaScript("document.querySelector('video').stopVideo();", completionHandler: nil)

    }
}

extension ChoiceQuizVideoViewController: WeeklyMissionCompleteViewControllerDelegate {
    func redeemDidTap() {
        self.delegate?.redeemDidTap()
    }

}
