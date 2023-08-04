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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    private let logger = Logger()
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - Window Cycle
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.overrideUserInterfaceStyle = .light
        
        if let user = Auth.auth().currentUser {
            logger.info("User is logged in.")
            
            Task {
                await self.setBasicUserInfo(email: user.email ?? FirestoreConstants.noUserEmail)
                let userInfo = try UPlusUser.getCurrentUser()
                let nft = await self.getMemberNft(userIndex: userInfo.userIndex,
                                            isVip: userInfo.userHasVipNft)
                
                let loginVM = LoginViewViewModel()
                let loginVC = LoginViewController(vm: loginVM)
                
                let missionVM = MissionMainViewViewModel(profileImage: nft,
                                                      username: userInfo.userNickname,
                                                      points: userInfo.userTotalPoint ?? 0,
                                                      maxPoints: 15,
                                                      level: 1,
                                                      numberOfMissions: Int64(userInfo.userTypeMissionArrayMap?.values.count ?? 0),
                                                      timeLeft: 12)
                
                let vm = MyPageViewViewModel(user: userInfo,
                                             isJustRegistered: false,
                                             isVip: userInfo.userHasVipNft,
                                             todayRank: UPlusServiceInfoConstant.totalMembers,
                                             missionViewModel: missionVM)
                let myPageVC = MyPageViewController(vm: vm)
                
                loginVC.navigationController?.addChild(myPageVC)
                window?.rootViewController = UINavigationController(rootViewController: myPageVC)
            }
            
            
        } else {
            logger.info("User is not logged in.")
            let loginVM = LoginViewViewModel()
            let loginVC = LoginViewController(vm: loginVM)
            window?.rootViewController = UINavigationController(rootViewController: loginVC)
        }
        
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

extension SceneDelegate {
    /// Save basic user login information.
    private func setBasicUserInfo(email: String) async {
        do {
            try await UPlusUser.saveCurrentUser(email: email)
        }
        catch {
            switch error {
            case FirestoreError.userNotFound:
                print("User not found -- \(error)")
            default:
                print("Error fetching user -- \(error)")
            }
        }
    }
    
    /// Get holding nft url string.
    private func getMemberNft(userIndex: Int64, isVip: Bool) async -> String {
        do {
            return try await self.firestoreManager.getMemberNft(userIndex: userIndex,
                                               isVip: isVip)
        }
        catch {
            print("Error fetching hold nft -- \(error)")
            return String()
        }
        
    }
    
}
