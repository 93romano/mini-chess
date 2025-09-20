import SpriteKit
import GameplayKit
import UIKit
import AVFoundation

class GameScene: SKScene {
    var board: Board!
    private let squareSize: CGFloat = 60.0
    private var boardNode: SKNode!
    private var pieceNodes: [[SKNode?]] = Array(repeating: Array(repeating: nil, count: 5), count: 5)
    private var moveIndicators: [Position: SKNode] = [:]
    private var gameManager: GameManager!
    private var turnLabel: SKLabelNode!
    private var moveSound: SKAction!
    private var captureSound: SKAction!
    
    private let lightSquareColor = UIColor(red: 240/255, green: 217/255, blue: 181/255, alpha: 1.0)
    private let darkSquareColor = UIColor(red: 181/255, green: 136/255, blue: 99/255, alpha: 1.0)
    
    override func didMove(to view: SKView) {
        setupBoard()
        setupBoardVisuals()
        setupPieces()
        setupUI()
        setupSounds()
        gameManager = GameManager(gameScene: self)
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
        
        board.squares = []
        
        for row in 0..<board.size {
            board.squares.append([])
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
    
    private func setupPieces() {
        for row in 0..<board.size {
            for col in 0..<board.size {
                if let piece = board.pieceAt(row: row, col: col) {
                    let pieceNode = PixelPieces.createPiece(
                        type: piece.type,
                        color: piece.color,
                        size: squareSize * 0.8
                    )
                    
                    let square = board.squares[row][col]
                    pieceNode.position = square.position
                    pieceNode.zPosition = 1
                    
                    boardNode.addChild(pieceNode)
                    
                    if pieceNodes.isEmpty {
                        pieceNodes = Array(repeating: Array(repeating: nil, count: 5), count: 5)
                    }
                    pieceNodes[row][col] = pieceNode
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        // Check if game over overlay was tapped
        if let node = atPoint(location) as? SKShapeNode, node.name == "gameOver" {
            restartGame()
            return
        }
        
        let boardLocation = touch.location(in: boardNode)
        
        if let position = convertLocationToBoardPosition(boardLocation) {
            gameManager.handleTouch(at: position)
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
        gameManager.handleTouch(at: position)
    }
    
    private func setupUI() {
        // Turn indicator
        turnLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        turnLabel.text = "White's Turn"
        turnLabel.fontSize = 24
        turnLabel.fontColor = .white
        turnLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        turnLabel.zPosition = 100
        addChild(turnLabel)
    }
    
    private func setupSounds() {
        // Use system sounds (can be replaced with custom sounds)
        moveSound = SKAction.run {
            AudioServicesPlaySystemSound(1104)
        }
        captureSound = SKAction.run {
            AudioServicesPlaySystemSound(1109)
        }
    }
    
    func createPixelExplosion(at position: CGPoint, color: UIColor) {
        let pixelSize: CGFloat = 4
        let explosionNode = SKNode()
        explosionNode.position = position
        explosionNode.zPosition = 50
        boardNode.addChild(explosionNode)
        
        // Create 8x8 pixels that explode outward
        for row in 0..<8 {
            for col in 0..<8 {
                let pixel = SKSpriteNode(color: color, size: CGSize(width: pixelSize, height: pixelSize))
                pixel.position = CGPoint(
                    x: CGFloat(col - 4) * pixelSize,
                    y: CGFloat(row - 4) * pixelSize
                )
                explosionNode.addChild(pixel)
                
                // Random explosion direction
                let angle = CGFloat.random(in: 0...(2 * .pi))
                let distance = CGFloat.random(in: 50...100)
                let moveVector = CGVector(
                    dx: cos(angle) * distance,
                    dy: sin(angle) * distance
                )
                
                let moveAction = SKAction.move(by: moveVector, duration: 0.5)
                let fadeAction = SKAction.fadeOut(withDuration: 0.5)
                let rotateAction = SKAction.rotate(byAngle: .pi * 4, duration: 0.5)
                let scaleAction = SKAction.scale(to: 0, duration: 0.5)
                
                let group = SKAction.group([moveAction, fadeAction, rotateAction, scaleAction])
                let removeAction = SKAction.removeFromParent()
                
                pixel.run(SKAction.sequence([group, removeAction]))
            }
        }
        
        // Remove explosion node after animation
        explosionNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            SKAction.removeFromParent()
        ]))
    }
    
    func updateTurnLabel(_ turn: PieceColor) {
        turnLabel.text = turn == .white ? "White's Turn" : "Black's Turn"
        
        // Pulse animation
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        turnLabel.run(SKAction.sequence([scaleUp, scaleDown]))
    }
    
    func highlightSquare(at position: Position, color: UIColor) {
        let square = board.squares[position.row][position.col]
        square.highlight(color: color)
    }
    
    func removeHighlight(at position: Position) {
        let square = board.squares[position.row][position.col]
        square.removeHighlight()
    }
    
    func showMoveIndicator(at position: Position, color: UIColor) {
        let indicator = SKShapeNode(circleOfRadius: 10)
        indicator.fillColor = color.withAlphaComponent(0.7)
        indicator.strokeColor = color
        indicator.lineWidth = 2
        
        let square = board.squares[position.row][position.col]
        indicator.position = square.position
        indicator.zPosition = 2
        
        boardNode.addChild(indicator)
        moveIndicators[position] = indicator
        
        // Pulse animation
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.3)
        indicator.run(SKAction.repeatForever(SKAction.sequence([fadeIn, fadeOut])))
    }
    
    func removeMoveIndicator(at position: Position) {
        moveIndicators[position]?.removeFromParent()
        moveIndicators[position] = nil
    }
    
    func animateMove(from: Position, to: Position, captured: Piece?) {
        guard let pieceNode = pieceNodes[from.row][from.col] else { return }
        
        // If capturing, create pixel explosion
        if let capturedNode = pieceNodes[to.row][to.col], let captured = captured {
            let capturedColor: UIColor = captured.color == .white ? .white : .darkGray
            
            createPixelExplosion(at: capturedNode.position, color: capturedColor)
            
            capturedNode.removeFromParent()
            
            run(captureSound)
        } else {
            run(moveSound)
        }
        
        // Move piece
        let targetSquare = board.squares[to.row][to.col]
        
        let liftAction = SKAction.scale(to: 1.2, duration: 0.1)
        let moveAction = SKAction.move(to: targetSquare.position, duration: 0.3)
        let dropAction = SKAction.scale(to: 1.0, duration: 0.1)
        
        pieceNode.run(SKAction.sequence([liftAction, moveAction, dropAction]))
        
        // Update piece nodes array
        pieceNodes[to.row][to.col] = pieceNode
        pieceNodes[from.row][from.col] = nil
    }
    
    func showGameOver(winner: PieceColor) {
        let overlayNode = SKShapeNode(rectOf: CGSize(width: 300, height: 150))
        overlayNode.fillColor = .black
        overlayNode.strokeColor = .white
        overlayNode.lineWidth = 3
        overlayNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlayNode.zPosition = 200
        
        let winnerLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        winnerLabel.text = "\(winner == .white ? "White" : "Black") Wins!"
        winnerLabel.fontSize = 32
        winnerLabel.fontColor = .white
        winnerLabel.position = CGPoint(x: 0, y: 20)
        overlayNode.addChild(winnerLabel)
        
        let restartLabel = SKLabelNode(fontNamed: "Helvetica")
        restartLabel.text = "Tap to restart"
        restartLabel.fontSize = 18
        restartLabel.fontColor = .lightGray
        restartLabel.position = CGPoint(x: 0, y: -20)
        overlayNode.addChild(restartLabel)
        
        addChild(overlayNode)
        
        // Restart on tap
        overlayNode.name = "gameOver"
    }
    
    private func restartGame() {
        removeAllChildren()
        pieceNodes = Array(repeating: Array(repeating: nil, count: 5), count: 5)
        moveIndicators = [:]
        
        setupBoard()
        setupBoardVisuals()
        setupPieces()
        setupUI()
        gameManager = GameManager(gameScene: self)
    }
}
