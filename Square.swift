import SpriteKit
import UIKit

class Square: SKSpriteNode {
    let position: Position
    var originalColor: UIColor
    
    init(position: Position, size: CGSize, color: UIColor) {
        self.position = position
        self.originalColor = color
        
        let texture = SKTexture()
        super.init(texture: texture, color: color, size: size)
        
        self.colorBlendFactor = 1.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func highlight(color: UIColor) {
        self.color = color
    }
    
    func removeHighlight() {
        self.color = originalColor
    }
}