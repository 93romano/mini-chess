import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("🎬 SceneDelegate willConnectTo 호출됨")

        guard let windowScene = (scene as? UIWindowScene) else {
            print("❌ WindowScene 캐스팅 실패")
            return
        }
        print("✅ WindowScene 생성 성공")

        window = UIWindow(windowScene: windowScene)
        window?.frame = windowScene.coordinateSpace.bounds
        print("🪟 Window 생성됨 - frame: \(window?.frame ?? .zero)")

        let viewController = GameViewController()
        print("🎮 GameViewController 생성됨")

        window?.rootViewController = viewController
        print("🎯 rootViewController 설정됨")

        window?.makeKeyAndVisible()
        print("👁️ window makeKeyAndVisible 호출됨")

        // Ensure the window scene is properly configured
        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 300, height: 300)
        windowScene.sizeRestrictions?.maximumSize = CGSize(width: 1200, height: 1200)
        print("📏 WindowScene 크기 제한 설정됨")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}