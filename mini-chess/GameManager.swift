import SpriteKit

class GameManager {
    var currentTurn: PieceColor = .white
    weak var gameScene: GameScene?
    var selectedPiece: Piece?
    var selectedPosition: Position?
    var possibleMoves: [Position] = []
    var aiEnabled: Bool = true
    var aiColor: PieceColor = .black
    var aiDifficulty: AIDifficulty = .medium
    var aiTimeLimit: TimeInterval = 10
    private let aiEngine = AIEngine()
    private var aiWorkItem: DispatchWorkItem?
    
    init(gameScene: GameScene) {
        self.gameScene = gameScene
        DispatchQueue.main.async { [weak self] in
            self?.triggerAIIfNeeded()
        }
    }
    
    func handleTouch(at position: Position) {
        guard let scene = gameScene else { return }
            if selectedPiece != nil {
            // Already have a piece selected
            if possibleMoves.contains(position) {
                // Valid move
                movePiece(from: selectedPosition!, to: position)
            } else if let piece = scene.board.pieceAt(row: position.row, col: position.col),
                      piece.color == currentTurn {
                // Select new piece of same color
                selectPiece(at: position)
            } else {
                // Deselect
                deselectPiece()
            }
        } else {
            // No piece selected yet
            if let piece = scene.board.pieceAt(row: position.row, col: position.col),
               piece.color == currentTurn {
                selectPiece(at: position)
            }
        }
    }
    
    func selectPiece(at position: Position) {
        guard let scene = gameScene,
              let piece = scene.board.pieceAt(row: position.row, col: position.col) else { return }
        
        deselectPiece()
        
        selectedPiece = piece
        selectedPosition = position
        possibleMoves = piece.possibleMoves(on: scene.board)
        
        // Highlight selected square
        scene.highlightSquare(at: position, color: .yellow)
        
        // Show possible moves
        for move in possibleMoves {
            let isCapture = scene.board.pieceAt(row: move.row, col: move.col) != nil
            let color: UIColor = isCapture ? .red : .green
            scene.showMoveIndicator(at: move, color: color)
        }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    func deselectPiece() {
        guard let scene = gameScene else { return }
        
        if let pos = selectedPosition {
            scene.removeHighlight(at: pos)
        }
        
        for move in possibleMoves {
            scene.removeMoveIndicator(at: move)
        }
        
        selectedPiece = nil
        selectedPosition = nil
        possibleMoves = []
    }
    
    func movePiece(from: Position, to: Position) {
        guard let scene = gameScene else { return }
        
        let capturedPiece = scene.board.movePiece(from: from, to: to)
        scene.animateMove(from: from, to: to, captured: capturedPiece)
        
        deselectPiece()
        
        // Check for game over (king captured)
        if let captured = capturedPiece, captured.type == .king {
            gameOver(winner: currentTurn)
            return
        }
        
        // Switch turns
        currentTurn = (currentTurn == .white) ? .black : .white
        scene.updateTurnLabel(currentTurn)
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        triggerAIIfNeeded()
    }
    
    func gameOver(winner: PieceColor) {
        guard let scene = gameScene else { return }
        scene.showGameOver(winner: winner)
        
        // Heavy haptic for game over
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
    }

    func triggerAIIfNeeded() {
        guard aiEnabled, let scene = gameScene else { return }
        guard currentTurn == aiColor else { return }

        aiWorkItem?.cancel()
        let boardCopy = scene.board.clone()
        let color = aiColor
        let difficulty = aiDifficulty
        let timeLimit = aiTimeLimit

        let work = DispatchWorkItem { [weak self] in
            let move = self?.aiEngine.chooseMove(board: boardCopy, for: color, difficulty: difficulty, timeLimit: timeLimit)
            DispatchQueue.main.async {
                guard let self = self, self.currentTurn == color else { return }
                if let m = move {
                    self.movePiece(from: m.from, to: m.to)
                }
            }
        }
        aiWorkItem = work
        DispatchQueue.global(qos: .userInitiated).async(execute: work)
    }
}
