import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func loadView() {
        self.view = SKView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔍 ViewController viewDidLoad 호출됨")

        guard let skView = self.view as? SKView else {
            print("❌ SKView 생성 실패")
            return
        }

        print("🔍 SKView 생성 성공")
        print("🔍 SKView bounds: \(skView.bounds)")

        // Configure SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        skView.shouldCullNonVisibleNodes = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let skView = self.view as? SKView else { return }

        print("🔍 viewDidAppear - SKView bounds: \(skView.bounds)")

        // Create and present scene when view is properly sized
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        print("🔍 GameScene 생성됨 - size: \(scene.size)")
        skView.presentScene(scene)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
