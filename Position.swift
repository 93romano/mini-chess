import Foundation

struct Position: Equatable {
    let row: Int
    let col: Int
    
    func isValid(boardSize: Int) -> Bool {
        return row >= 0 && row < boardSize && col >= 0 && col < boardSize
    }
}