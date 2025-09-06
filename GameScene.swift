import SpriteKit
import GameplayKit
import UIKit

class GameScene: SKScene {
    private var board: Board!
    private let squareSize: CGFloat = 60.0
    private var boardNode: SKNode!
    
    private let lightSquareColor = UIColor(red: 240/255, green: 217/255, blue: 181/255, alpha: 1.0)
    private let darkSquareColor = UIColor(red: 181/255, green: 136/255, blue: 99/255, alpha: 1.0)
    
    override func didMove(to view: SKView) {
        setupBoard()
        setupBoardVisuals()
    }
    
    private func setupBoard() {
        board = Board()
        board.setupInitialPosition()
        boardNode = SKNode()
        addChild(boardNode)
    }
    
    private func setupBoardVisuals() {
        let boardSize = CGFloat(board.size) * squareSize
        let startX = -boardSize / 2 + squareSize / 2
        let startY = boardSize / 2 - squareSize / 2
        
        board.squares = Array(repeating: Array(repeating: Square(position: Position(row: 0, col: 0), size: CGSize.zero, color: UIColor.clear)), count: board.size)
        
        for row in 0..<board.size {
            board.squares[row] = []
            for col in 0..<board.size {
                let isLightSquare = (row + col) % 2 == 0
                let squareColor = isLightSquare ? lightSquareColor : darkSquareColor
                
                let square = Square(
                    position: Position(row: row, col: col),
                    size: CGSize(width: squareSize, height: squareSize),
                    color: squareColor
                )
                
                let xPos = startX + CGFloat(col) * squareSize
                let yPos = startY - CGFloat(row) * squareSize
                square.position = CGPoint(x: xPos, y: yPos)
                
                board.squares[row].append(square)
                boardNode.addChild(square)
            }
        }
        
        centerBoard()
    }
    
    private func centerBoard() {
        boardNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: boardNode)
        
        if let position = convertLocationToBoardPosition(location) {
            handleSquareTapped(at: position)
        }
    }
    
    private func convertLocationToBoardPosition(_ location: CGPoint) -> Position? {
        let boardSize = CGFloat(board.size) * squareSize
        let startX = -boardSize / 2
        let startY = boardSize / 2
        
        let col = Int((location.x - startX) / squareSize)
        let row = Int((startY - location.y) / squareSize)
        
        let position = Position(row: row, col: col)
        return board.isValidPosition(position) ? position : nil
    }
    
    private func handleSquareTapped(at position: Position) {
        let square = board.squares[position.row][position.col]
        let piece = board.pieceAt(row: position.row, col: position.col)
        
        if let piece = piece {
            print("Tapped on \(piece.color) \(piece.type) at (\(position.row), \(position.col))")
            square.highlight(color: UIColor.yellow)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                square.removeHighlight()
            }
        } else {
            print("Tapped on empty square at (\(position.row), \(position.col))")
        }
    }
}