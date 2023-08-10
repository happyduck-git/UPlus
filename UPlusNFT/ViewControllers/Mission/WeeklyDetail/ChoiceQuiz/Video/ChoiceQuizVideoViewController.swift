//
//  ChoiceQuizViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import UIKit
import WebKit
import Combine

final class ChoiceQuizVideoViewController: UIViewController {

    //MARK: - Dependency
    private let vm: ChoiceQuizVideoViewViewModel
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let videoPlayer: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.backgroundColor = .systemGray4
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 10
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("선택완료!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
        
        self.setUI()
        self.setLayout()
        self.bind()
        
        self.playYTVideo()
    }
   
}

//MARK: - Set UI & Layout
extension ChoiceQuizVideoViewController {
    private func setUI() {
        self.view.addSubviews(self.videoPlayer,
                              self.label,
                              self.submitButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.videoPlayer.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.videoPlayer.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.videoPlayer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.videoPlayer.heightAnchor.constraint(equalToConstant: self.view.frame.height / 3.5),
            
            self.label.topAnchor.constraint(equalToSystemSpacingBelow: self.videoPlayer.bottomAnchor, multiplier: 2),
            self.label.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.label.trailingAnchor, multiplier: 2),
          
            self.submitButton.topAnchor.constraint(equalToSystemSpacingBelow: self.label.bottomAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.submitButton.bottomAnchor, multiplier: 3),
            self.submitButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 4),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.submitButton.trailingAnchor, multiplier: 4)
        ])
        self.submitButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

extension ChoiceQuizVideoViewController {
    private func bind() {
        self.vm.$imageUrls
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.label.text = "Captions: \(self.vm.mission.missionChoiceQuizCaptions)\n" + "ImageUrls: \($0)"
            }
            .store(in: &bindings)
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
        if url.contains("?") {
            return url + "&autoplay=1"
        } else {
            return url + "?autoplay=1"
        }
    }
}
