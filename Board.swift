import Foundation

class Board {
    let size = 5
    var squares: [[Square]] = []
    var pieces: [[Piece?]] = Array(repeating: Array(repeating: nil, count: 5), count: 5)
    
    func setupInitialPosition() {
        // Black pieces
        pieces[0][0] = Piece(type: .rook, color: .black, position: Position(row: 0, col: 0))
        pieces[0][1] = Piece(type: .knight, color: .black, position: Position(row: 0, col: 1))
        pieces[0][2] = Piece(type: .king, color: .black, position: Position(row: 0, col: 2))
        pieces[0][3] = Piece(type: .knight, color: .black, position: Position(row: 0, col: 3))
        pieces[0][4] = Piece(type: .rook, color: .black, position: Position(row: 0, col: 4))
        
        // White pieces
        pieces[4][0] = Piece(type: .rook, color: .white, position: Position(row: 4, col: 0))
        pieces[4][1] = Piece(type: .knight, color: .white, position: Position(row: 4, col: 1))
        pieces[4][2] = Piece(type: .king, color: .white, position: Position(row: 4, col: 2))
        pieces[4][3] = Piece(type: .knight, color: .white, position: Position(row: 4, col: 3))
        pieces[4][4] = Piece(type: .rook, color: .white, position: Position(row: 4, col: 4))
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
}