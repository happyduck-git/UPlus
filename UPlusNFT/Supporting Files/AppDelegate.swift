//
//  AppDelegate.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/20.
//
 
import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let barButtonAppearance = UIBarButtonItem.appearance()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        let backButtonImage = UIImage(named: ImageAssets.arrowHeadLeft)?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 10)
        barButtonAppearance.setBackButtonBackgroundImage(backButtonImage, for: .normal, barMetrics: .default)
        
        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .badge, .sound])
     }

     func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {

         // deep link처리 시 아래 url값 가지고 처리
         let userInfo = response.notification.request.content.userInfo
         if let id = userInfo["targetView"] as? String {
             // TODO: Specify a certain vc
             let vm = RoutineMissionDetailViewViewModel(missionType: .dailyExpGoodWorker)
             let vc = RoutineMissionDetailViewController(vm: vm)
             let navVC = UINavigationController(rootViewController: vc)
             
             self.window = UIWindow(frame: UIScreen.main.bounds)
             self.window?.rootViewController = navVC
             self.window?.makeKeyAndVisible()
         }
         
         completionHandler()
     }
    
}
