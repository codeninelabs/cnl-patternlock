//
//  extensions.swift
//  pattrnd
//
//  Created by Kevin Armstrong on 12/13/24.
//

extension Point {
    public func isAdjacent(to other: Point) -> Bool {
        let dx = abs(x - other.x)
        let dy = abs(y - other.y)
        
        return dx <= 1 && dy <= 1 && !(dx == 0 && dy == 0)
    }
}

extension Array where Element == Point {
    public func isValidPattern(gridSize: Int) -> Bool {
        guard count >= 2 else { return true }  // Single point or empty is valid
        
        // Check if all points are within grid bounds
        let isWithinBounds = self.allSatisfy { point in
            point.x >= 0 && point.x < gridSize &&
            point.y >= 0 && point.y < gridSize
        }
        
        guard isWithinBounds else { return false }
        
        // Check if points are adjacent and unique
        for i in 1..<count {
            let previousPoint = self[i-1]
            let currentPoint = self[i]
            
            // Check if points are adjacent
            if !previousPoint.isAdjacent(to: currentPoint) {
                return false
            }
            
            // Check if point was already used
            let previousPoints = self[0..<i]
            if previousPoints.contains(currentPoint) {
                return false
            }
        }
        
        return true
    }
}
