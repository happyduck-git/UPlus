//
//  SceneDelegate.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/20.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import OSLog
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Window Cycle
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        #if DEBUG
        UPlusLogger.logger.info("🐞Current in DEBUG mode.")
        #else
        UPlusLogger.logger.info("🎉Current in Release mode.")
        #endif
        
        window = UIWindow(windowScene: windowScene)
        window?.overrideUserInterfaceStyle = .light

        let vm = OnBoardingViewViewModel()
        let vc = OnBoardingViewController2(vm: vm)
        let navVC = UINavigationController(rootViewController: vc)
        
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }

        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        /// 이메일에서 sigin in 확인 후 앱으로 돌아온 후
        guard let webpageURL = userActivity.webpageURL else { return }
        let link = webpageURL.absoluteString
        if Auth.auth().isSignIn(withEmailLink: link) {
            UserDefaults.standard.set(link, forKey: FirebaseAuthConstants.firebaseAuthLinkKey)
            NotificationCenter.default.post(name: NSNotification.Name.signIn, object: nil)
        }
        
    }
    
}

