//
//  AppDelegate.swift
//  falcon
//
//  Created by 周明 on 2026/1/15.
//

import UIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Rotation Control
    /// 全局控制屏幕旋转方向
    /// 这个方法优先级最高，会覆盖 Info.plist 的设置
    /// 如果某个界面需要强制横屏，可以在这里动态修改返回值
    var orientationLock: UIInterfaceOrientationMask = .allButUpsideDown
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        MDFullscreenPopGesture.configure()
        SimpleRouter.shared.register(route: Route.self)
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
