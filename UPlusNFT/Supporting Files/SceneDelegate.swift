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

    let logger = Logger()
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.overrideUserInterfaceStyle = .light
        
        if Auth.auth().currentUser != nil {
            logger.info("User is logged in.")
            try? Auth.auth().signOut()
            /*
            setBasicUserInfo()
            
            let loginVM = LoginViewViewModel()
            let loginVC = LoginViewController(vm: loginVM)
            
            let postVM = PostViewViewModel()
            let postVC = PostViewController(vm: postVM)
            loginVC.navigationController?.addChild(postVC)
            window?.rootViewController = UINavigationController(rootViewController: postVC)
             */
        } else {
            logger.info("User is not logged in.")
            let loginVM = LoginViewViewModel()
            let loginVC = LoginViewController(vm: loginVM)
            window?.rootViewController = UINavigationController(rootViewController: loginVC)
        }

        /*
        // Check SignupCompelete VC
        let vm = SignUpViewViewModel()
        vm.welcomeNftImage = "https://i.seadn.io/gae/lW22aEwUE0IqGaYm5HRiMS8DwkDwsdjPpprEqYnBqo2s7gSR-JqcYOjU9LM6p32ujG_YAEd72aDyox-pdCVK10G-u1qZ3zAsn2r9?auto=format&dpr=1&w=200" //Temp
        let vc = SignUpCompleteViewController(vm: vm)
        
        window?.rootViewController = UINavigationController(rootViewController: vc)
        */
        
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

/// Save basic user login information.
extension SceneDelegate {
    private func setBasicUserInfo() {
        let userId = Auth.auth().currentUser?.uid ?? ""
        let username = Auth.auth().currentUser?.displayName ?? FirestoreConstants.noUsername
        let profileImageUrl = Auth.auth().currentUser?.photoURL
        var profileImageUrlString = ""
        if let profileImageUrl = profileImageUrl {
            profileImageUrlString = String(describing: profileImageUrl)
        }
        
        UserDefaults.standard.setValue(userId, forKey: UserDefaultsConstants.userId)
        UserDefaults.standard.setValue(username, forKey: UserDefaultsConstants.username)
        UserDefaults.standard.setValue(profileImageUrlString, forKey: UserDefaultsConstants.profileImage)
        
    }
}
