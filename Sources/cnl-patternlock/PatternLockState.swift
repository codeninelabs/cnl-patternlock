//
//  PatternLockState.swift
//  pattrnd
//
//  Created by Kevin Armstrong on 12/14/24.
//

import Foundation

private let INVALID_PATTERN_ERROR_MSG = "invalid pattern - dots must be adjacent and not repeated"

@MainActor
public class PatternLockState: ObservableObject {
    @Published var dots: [[DotState]]
    @Published var selectedDots: [Point] = []
    @Published var currentPosition: CGPoint?
    @Published var isShowingError: Bool = false
    @Published var validationError: String?
    private let gridSize: Int
    
    public init(gridSize: Int = 3, initialPattern: [Point]? = nil) {
        self.gridSize = gridSize
        dots = (0..<gridSize).map { row in
            (0..<gridSize).map { col in
                DotState(position: Point(x: col, y: row))
            }
        }
        
        if let pattern = initialPattern, pattern.isValidPattern(gridSize: gridSize) {
            selectedDots = pattern
            updateSelectedDots()
        } else {
            validationError = INVALID_PATTERN_ERROR_MSG
            showError()
        }
    }
    
    public func setPattern(pattern: [Point]) {
        reset()
        if pattern.isValidPattern(gridSize: gridSize) {
            selectedDots = pattern
            updateSelectedDots()
        } else {
            validationError = INVALID_PATTERN_ERROR_MSG
            showError()
            selectedDots = pattern
        }
    }
    
    public func reset() {
        selectedDots.removeAll()
        currentPosition = nil
        isShowingError = false
        validationError = nil
        for row in 0..<dots.count {
            for col in 0..<dots[row].count {
                dots[row][col].isSelected = false
            }
        }
    }
    
    public func validatePattern() -> PatternLockValidationResult {
        if !selectedDots.isValidPattern(gridSize: gridSize) {
            return .failure(INVALID_PATTERN_ERROR_MSG)
        }
        return .success
    }
    
    public func showError() {
        isShowingError = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.isShowingError = false
        }
    }
    
    private func updateSelectedDots() {
        for point in selectedDots {
            if let row = dots.firstIndex(where: { $0.contains(where: { $0.position == point }) }),
               let col = dots[row].firstIndex(where: { $0.position == point }) {
                dots[row][col].isSelected = true
            }
        }
    }
}
