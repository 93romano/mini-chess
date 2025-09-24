import Foundation

enum PieceType {
    case rook
    case knight
    case bishop
    case pawn
    case king
}

enum PieceColor {
    case white
    case black
}

class Piece {
    let type: PieceType
    let color: PieceColor
    var currentPosition: Position
    
    init(type: PieceType, color: PieceColor, position: Position) {
        self.type = type
        self.color = color
        self.currentPosition = position
    }
    
    func possibleMoves(on board: Board) -> [Position] {
        var moves: [Position] = []
        
        switch type {
        case .king:
            // King can move one square in any direction
            let directions = [
                (-1, -1), (-1, 0), (-1, 1),
                (0, -1),           (0, 1),
                (1, -1),  (1, 0),  (1, 1)
            ]
            
            for (dRow, dCol) in directions {
                let newPos = Position(row: currentPosition.row + dRow, col: currentPosition.col + dCol)
                if canMove(to: newPos, on: board) {
                    moves.append(newPos)
                }
            }
            
        case .rook:
            // Rook moves horizontally or vertically
            let directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]
            
            for (dRow, dCol) in directions {
                var distance = 1
                while true {
                    let newPos = Position(row: currentPosition.row + dRow * distance,
                                        col: currentPosition.col + dCol * distance)
                    
                    if !board.isValidPosition(newPos) {
                        break
                    }
                    
                    if let piece = board.pieceAt(row: newPos.row, col: newPos.col) {
                        if piece.color != self.color {
                            moves.append(newPos) // Can capture
                        }
                        break // Can't go through pieces
                    }
                    
                    moves.append(newPos)
                    distance += 1
                }
            }
        case .bishop:
            // Bishop moves diagonally
            let directions = [(-1, -1), (-1, 1), (1, -1), (1, 1)]
            for (dRow, dCol) in directions {
                var distance = 1
                while true {
                    let newPos = Position(row: currentPosition.row + dRow * distance,
                                          col: currentPosition.col + dCol * distance)
                    if !board.isValidPosition(newPos) { break }
                    if let piece = board.pieceAt(row: newPos.row, col: newPos.col) {
                        if piece.color != self.color { moves.append(newPos) }
                        break
                    }
                    moves.append(newPos)
                    distance += 1
                }
            }
        
        case .knight:
            // Knight moves in L-shape
            let knightMoves = [
                (-2, -1), (-2, 1), (-1, -2), (-1, 2),
                (1, -2), (1, 2), (2, -1), (2, 1)
            ]
            
            for (dRow, dCol) in knightMoves {
                let newPos = Position(row: currentPosition.row + dRow, col: currentPosition.col + dCol)
                if canMove(to: newPos, on: board) {
                    moves.append(newPos)
                }
            }
        case .pawn:
            // Pawns move forward 1; capture diagonally forward 1. No double step, en passant, or promotion.
            let dir = (color == .white) ? -1 : 1
            // Forward move
            let forward = Position(row: currentPosition.row + dir, col: currentPosition.col)
            if board.isValidPosition(forward) && board.pieceAt(row: forward.row, col: forward.col) == nil {
                moves.append(forward)
            }
            // Diagonal captures
            let caps = [Position(row: currentPosition.row + dir, col: currentPosition.col - 1),
                        Position(row: currentPosition.row + dir, col: currentPosition.col + 1)]
            for p in caps {
                if board.isValidPosition(p), let tp = board.pieceAt(row: p.row, col: p.col), tp.color != self.color {
                    moves.append(p)
                }
            }
        }
        
        return moves
    }
    
    func canMove(to position: Position, on board: Board) -> Bool {
        // Check if position is valid
        if !board.isValidPosition(position) {
            return false
        }
        
        // Check if there's a piece at the target position
        if let targetPiece = board.pieceAt(row: position.row, col: position.col) {
            // Can't capture own piece
            return targetPiece.color != self.color
        }
        
        return true
    }
}
