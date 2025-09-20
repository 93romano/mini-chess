import Foundation

struct Position: Equatable, Hashable {
    let row: Int
    let col: Int
    
    func isValid(boardSize: Int) -> Bool {
        return row >= 0 && row < boardSize && col >= 0 && col < boardSize
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(row)
        hasher.combine(col)
    }
}
