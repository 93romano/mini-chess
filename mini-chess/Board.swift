import Foundation

class Board {
    let size: Int
    var squares: [[Square]] = []
    var pieces: [[Piece?]]

    init(size: Int = 5) {
        self.size = size
        self.pieces = Array(repeating: Array(repeating: nil, count: size), count: size)
    }
    
    func setupInitialPosition() {
        if size == 5 {
            // 5x5: R N K N R
            pieces[0][0] = Piece(type: .rook, color: .black, position: Position(row: 0, col: 0))
            pieces[0][1] = Piece(type: .knight, color: .black, position: Position(row: 0, col: 1))
            pieces[0][2] = Piece(type: .king, color: .black, position: Position(row: 0, col: 2))
            pieces[0][3] = Piece(type: .knight, color: .black, position: Position(row: 0, col: 3))
            pieces[0][4] = Piece(type: .rook, color: .black, position: Position(row: 0, col: 4))

            pieces[4][0] = Piece(type: .rook, color: .white, position: Position(row: 4, col: 0))
            pieces[4][1] = Piece(type: .knight, color: .white, position: Position(row: 4, col: 1))
            pieces[4][2] = Piece(type: .king, color: .white, position: Position(row: 4, col: 2))
            pieces[4][3] = Piece(type: .knight, color: .white, position: Position(row: 4, col: 3))
            pieces[4][4] = Piece(type: .rook, color: .white, position: Position(row: 4, col: 4))

            // Optional pawns on odd columns (1,3)
            for c in 0..<size where c % 2 == 1 {
                pieces[1][c] = Piece(type: .pawn, color: .black, position: Position(row: 1, col: c))
                pieces[size - 2][c] = Piece(type: .pawn, color: .white, position: Position(row: size - 2, col: c))
            }
            return
        }

        if size == 7 {
            // 7x7: R N B K B N R
            let types: [PieceType] = [.rook, .knight, .bishop, .king, .bishop, .knight, .rook]
            for c in 0..<size {
                pieces[0][c] = Piece(type: types[c], color: .black, position: Position(row: 0, col: c))
                pieces[size - 1][c] = Piece(type: types[c], color: .white, position: Position(row: size - 1, col: c))
            }
            // Pawns on odd columns only (1,3,5)
            for c in 0..<size where c % 2 == 1 {
                pieces[1][c] = Piece(type: .pawn, color: .black, position: Position(row: 1, col: c))
                pieces[size - 2][c] = Piece(type: .pawn, color: .white, position: Position(row: size - 2, col: c))
            }
            return
        }
        
        // Fallback: place only kings centered for other sizes
        let mid = size / 2
        pieces[0][mid] = Piece(type: .king, color: .black, position: Position(row: 0, col: mid))
        pieces[size - 1][mid] = Piece(type: .king, color: .white, position: Position(row: size - 1, col: mid))
    }
    
    func pieceAt(row: Int, col: Int) -> Piece? {
        guard isValidPosition(Position(row: row, col: col)) else { return nil }
        return pieces[row][col]
    }
    
    func movePiece(from: Position, to: Position) -> Piece? {
        guard isValidPosition(from) && isValidPosition(to) else { return nil }
        
        let piece = pieces[from.row][from.col]
        let capturedPiece = pieces[to.row][to.col]
        
        pieces[from.row][from.col] = nil
        pieces[to.row][to.col] = piece
        
        // Update piece's current position
        piece?.currentPosition = to
        
        return capturedPiece
    }
    
    func isValidPosition(_ position: Position) -> Bool {
        return position.isValid(boardSize: size)
    }

    func generateMoves(for color: PieceColor) -> [Move] {
        var result: [Move] = []
        for r in 0..<size {
            for c in 0..<size {
                if let piece = pieces[r][c], piece.color == color {
                    let moves = piece.possibleMoves(on: self)
                    for m in moves {
                        result.append(Move(from: Position(row: r, col: c), to: m))
                    }
                }
            }
        }
        return result
    }

    func apply(_ move: Move) -> Piece? {
        let piece = pieces[move.from.row][move.from.col]
        let captured = pieces[move.to.row][move.to.col]
        pieces[move.to.row][move.to.col] = piece
        pieces[move.from.row][move.from.col] = nil
        piece?.currentPosition = move.to
        return captured
    }

    func undo(_ move: Move, captured: Piece?) {
        let piece = pieces[move.to.row][move.to.col]
        pieces[move.from.row][move.from.col] = piece
        pieces[move.to.row][move.to.col] = captured
        piece?.currentPosition = move.from
    }

    func clone() -> Board {
        let b = Board(size: size)
        for r in 0..<size {
            for c in 0..<size {
                if let p = pieces[r][c] {
                    let cp = Piece(type: p.type, color: p.color, position: p.currentPosition)
                    b.pieces[r][c] = cp
                }
            }
        }
        return b
    }

    func hasKing(color: PieceColor) -> Bool {
        for r in 0..<size {
            for c in 0..<size {
                if let p = pieces[r][c], p.type == .king, p.color == color { return true }
            }
        }
        return false
    }
}
