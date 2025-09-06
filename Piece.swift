import Foundation

enum PieceType {
    case rook
    case knight
    case king
}

enum PieceColor {
    case white
    case black
}

struct Piece {
    let type: PieceType
    let color: PieceColor
    
    init(type: PieceType, color: PieceColor) {
        self.type = type
        self.color = color
    }
}