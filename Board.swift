import Foundation

class Board {
    let size = 5
    var squares: [[Square]] = []
    var pieces: [[Piece?]] = Array(repeating: Array(repeating: nil, count: 5), count: 5)
    
    func setupInitialPosition() {
        pieces[0][0] = Piece(type: .rook, color: .black)
        pieces[0][1] = Piece(type: .knight, color: .black)
        pieces[0][2] = Piece(type: .king, color: .black)
        pieces[0][3] = Piece(type: .knight, color: .black)
        pieces[0][4] = Piece(type: .rook, color: .black)
        
        pieces[4][0] = Piece(type: .rook, color: .white)
        pieces[4][1] = Piece(type: .knight, color: .white)
        pieces[4][2] = Piece(type: .king, color: .white)
        pieces[4][3] = Piece(type: .knight, color: .white)
        pieces[4][4] = Piece(type: .rook, color: .white)
    }
    
    func pieceAt(row: Int, col: Int) -> Piece? {
        guard isValidPosition(Position(row: row, col: col)) else { return nil }
        return pieces[row][col]
    }
    
    func movePiece(from: Position, to: Position) {
        guard isValidPosition(from) && isValidPosition(to) else { return }
        
        let piece = pieces[from.row][from.col]
        pieces[from.row][from.col] = nil
        pieces[to.row][to.col] = piece
    }
    
    func isValidPosition(_ position: Position) -> Bool {
        return position.isValid(boardSize: size)
    }
}