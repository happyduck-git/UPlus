//
//  MyPageSegmentedViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/31.
//

import UIKit

final class MyPageSegmentedViewController: SJSegmentedViewController {
    var selectedSegment: SJSegmentTab?
    
    var headerVC = ZeroHeaderViewController()
    var firstVC = FirstViewController()
    var secondVC = SecondViewController()
    
    override func viewDidLoad() {
        
        self.headerViewController = headerVC
        firstVC.title = "미션"
        secondVC.title = "이벤트"
        
        self.segmentControllers = [
            firstVC, secondVC
        ]
        
        headerViewHeight = 500
        selectedSegmentViewHeight = 3.0
        headerViewOffsetHeight = 30.0
        segmentTitleColor = .gray
        selectedSegmentViewColor = .green
        segmentShadow = SJShadow.light()
        segmentBounces = false
        delegate = self
        
        super.viewDidLoad()
    }
}

extension MyPageSegmentedViewController: SJSegmentedViewControllerDelegate {

    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {

        if selectedSegment != nil {
            selectedSegment?.titleColor(.lightGray)
        }

        if segments.count > 0 {

            selectedSegment = segments[index]
            selectedSegment?.titleColor(.red)
        }
    }
}
