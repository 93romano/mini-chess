import Foundation

enum AIDifficulty {
    case easy
    case medium
    case hard
}

final class AIEngine {
    private var timeLimit: TimeInterval = 10
    private var deadline: TimeInterval = 0
    private var lastBest: Move?

    func chooseMove(board: Board, for color: PieceColor, difficulty: AIDifficulty, timeLimit: TimeInterval) -> Move? {
        self.timeLimit = timeLimit
        self.deadline = CFAbsoluteTimeGetCurrent() + timeLimit
        self.lastBest = nil

        let maxDepth: Int
        switch difficulty {
        case .easy: maxDepth = 2
        case .medium: maxDepth = 4
        case .hard: maxDepth = 8
        }

        var depth = 1
        while depth <= maxDepth {
            if timeUp() { break }
            if let move = search(board: board.clone(), depth: depth, sideToMove: color) {
                lastBest = move
            }
            depth += 1
        }

        return lastBest
    }

    private func timeUp() -> Bool {
        return CFAbsoluteTimeGetCurrent() >= deadline
    }

    private func search(board: Board, depth: Int, sideToMove: PieceColor) -> Move? {
        var alpha = Int.min / 4
        var beta = Int.max / 4
        var bestMove: Move?
        let moves = orderedMoves(board: board, for: sideToMove)
        if moves.isEmpty { return nil }

        for move in moves {
            if timeUp() { break }
            let captured = board.apply(move)
            let value = -negamax(board: board, depth: depth - 1, sideToMove: opposite(sideToMove), alpha: &alpha, beta: &beta, perspective: sideToMove)
            board.undo(move, captured: captured)
            if value > alpha {
                alpha = value
                bestMove = move
            }
        }
        return bestMove
    }

    private func negamax(board: Board, depth: Int, sideToMove: PieceColor, alpha: inout Int, beta: inout Int, perspective: PieceColor) -> Int {
        if timeUp() { return evaluate(board: board, perspective: perspective) }

        if !board.hasKing(color: perspective == .white ? .black : .white) {
            return 100000
        }
        if !board.hasKing(color: perspective) {
            return -100000
        }

        if depth == 0 {
            return evaluate(board: board, perspective: perspective)
        }

        var a = alpha
        var value = Int.min / 4
        let moves = orderedMoves(board: board, for: sideToMove)
        if moves.isEmpty {
            return evaluate(board: board, perspective: perspective)
        }

        for move in moves {
            if timeUp() { break }
            let captured = board.apply(move)
            var nb = -beta
            var na = -a
            let score = -negamax(board: board, depth: depth - 1, sideToMove: opposite(sideToMove), alpha: &nb, beta: &na, perspective: perspective)
            board.undo(move, captured: captured)
            if score > value { value = score }
            if value > a { a = value }
            if a >= beta { break }
        }
        return value
    }

    private func orderedMoves(board: Board, for color: PieceColor) -> [Move] {
        let moves = board.generateMoves(for: color)
        let center = (board.size - 1) / 2
        return moves.sorted { lhs, rhs in
            let lcap = board.pieceAt(row: lhs.to.row, col: lhs.to.col) != nil
            let rcap = board.pieceAt(row: rhs.to.row, col: rhs.to.col) != nil
            if lcap != rcap { return lcap && !rcap }
            let ldist = abs(lhs.to.row - center) + abs(lhs.to.col - center)
            let rdist = abs(rhs.to.row - center) + abs(rhs.to.col - center)
            return ldist < rdist
        }
    }

    private func evaluate(board: Board, perspective: PieceColor) -> Int {
        var score = 0
        for r in 0..<board.size {
            for c in 0..<board.size {
                if let p = board.pieces[r][c] {
                    let v: Int
                    switch p.type {
                    case .king: v = 10000
                    case .bishop: v = 330
                    case .rook: v = 500
                    case .knight: v = 300
                    case .pawn: v = 100
                    }
                    let center = (board.size - 1) / 2
                    let centerBonus = 20 - 5 * (abs(center - r) + abs(center - c))
                    let sign = (p.color == perspective) ? 1 : -1
                    score += sign * (v + centerBonus)
                }
            }
        }
        let myMob = board.generateMoves(for: perspective).count
        let opMob = board.generateMoves(for: opposite(perspective)).count
        score += (myMob - opMob) * 5
        return score
    }

    private func opposite(_ c: PieceColor) -> PieceColor { c == .white ? .black : .white }
}
