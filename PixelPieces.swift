import SpriteKit
import UIKit

class PixelPieces {
    // King pattern (8x8)
    static let kingPattern = [
        "   ++   ",
        "  ++++  ",
        "   ++   ",
        " ###### ",
        "########",
        "##XXXX##",
        "########",
        " ###### "
    ]
    
    // Rook pattern (8x8)
    static let rookPattern = [
        " ## ##  ",
        " ###### ",
        " ###### ",
        "  ####  ",
        "  ####  ",
        " ###### ",
        "########",
        "########"
    ]
    
    // Knight pattern (8x8)
    static let knightPattern = [
        "   ###  ",
        "  ##### ",
        " ####### ",
        "###  ###",
        "    ####",
        "   #### ",
        " ###### ",
        "########"
    ]
    
    // Create a function to generate SKNode from pattern
    static func createPiece(type: PieceType, color: PieceColor, size: CGFloat) -> SKNode {
        let pattern: [String]
        switch type {
        case .king:
            pattern = kingPattern
        case .rook:
            pattern = rookPattern
        case .knight:
            pattern = knightPattern
        }
        
        let pieceNode = SKNode()
        let pixelSize = size / 8.0
        
        // Define colors based on piece color
        let colorMap: [Character: UIColor]
        if color == .white {
            colorMap = [
                "#": UIColor.white,
                "X": UIColor.lightGray,
                "+": UIColor.systemYellow,
                " ": UIColor.clear
            ]
        } else {
            colorMap = [
                "#": UIColor.darkGray,
                "X": UIColor.black,
                "+": UIColor.systemYellow,
                " ": UIColor.clear
            ]
        }
        
        // Create pixels from pattern
        for (row, line) in pattern.enumerated() {
            for (col, char) in line.enumerated() {
                if let pixelColor = colorMap[char], pixelColor != .clear {
                    let pixel = SKSpriteNode(color: pixelColor, size: CGSize(width: pixelSize - 1, height: pixelSize - 1))
                    pixel.position = CGPoint(
                        x: CGFloat(col) * pixelSize - size/2 + pixelSize/2,
                        y: size/2 - CGFloat(row) * pixelSize - pixelSize/2
                    )
                    pieceNode.addChild(pixel)
                }
            }
        }
        
        return pieceNode
    }
}