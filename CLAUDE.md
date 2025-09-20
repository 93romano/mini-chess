# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a mini-chess iOS game built with SpriteKit. It's a simplified chess game on a 5x5 board with a reduced piece set (King, Rook, Knight only). The game features pixel art pieces, smooth animations, sound effects, and haptic feedback.

## Build Commands

Build the project:
```bash
xcodebuild -project mini-chess.xcodeproj -scheme mini-chess -configuration Debug build
```

Run tests:
```bash
xcodebuild -project mini-chess.xcodeproj -scheme mini-chess -configuration Debug test
```

Clean build:
```bash
xcodebuild -project mini-chess.xcodeproj -scheme mini-chess clean
```

## Architecture

### Core Components

- **GameScene** (`GameScene.swift`): Main SpriteKit scene that handles rendering, touch input, animations, and UI. Controls the game board visuals, piece movements, and game state presentation.

- **GameManager** (`GameManager.swift`): Game logic controller that manages turn-based gameplay, piece selection, move validation, and win conditions. Acts as the bridge between user input and game state.

- **Board** (`Board.swift`): Represents the 5x5 game board, manages piece positions in a 2D array, and handles piece movement operations.

- **Piece** (`Piece.swift`): Defines piece types (King, Rook, Knight), colors, and movement logic. Each piece calculates its own valid moves based on chess rules adapted for the 5x5 board.

- **PixelPieces** (`PixelPieces.swift`): Creates pixel art representations of chess pieces using 8x8 character patterns. Generates SKNode graphics from ASCII art patterns.

### Supporting Classes

- **Position** (`Position.swift`): Coordinate system for board positions (row, col)
- **Square** (`Square.swift`): Visual representation of board squares with highlighting capabilities
- **GameViewController** (`GameViewController.swift`): UIKit view controller that hosts the SpriteKit scene

### Game Rules

- 5x5 board with reduced piece set
- Starting position: Rook-Knight-King-Knight-Rook on both sides
- King capture wins the game (no checkmate logic)
- Standard chess movement rules apply within the smaller board

### Visual Features

- Pixel art pieces with 8x8 patterns
- Smooth piece movement animations with scale effects  
- Particle explosion effects when pieces are captured
- Square highlighting for selected pieces and valid moves
- Turn indicator with pulse animations

### Technical Notes

- Uses SpriteKit framework for 2D game rendering
- Implements custom touch handling for piece selection and movement
- Audio feedback using system sounds (AudioServicesPlaySystemSound)
- Haptic feedback for piece selection and moves
- Game state managed through delegation pattern between GameManager and GameScene