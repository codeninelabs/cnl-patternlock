// The Swift Programming Language
// https://docs.swift.org/swift-book
//
//  PatternLockView.swift
//  pattrnd
//
//  Created by Kevin Armstrong on 12/14/24.
//
import SwiftUI

public struct PatternLockView: View {
    @ObservedObject private var state: PatternLockState
    private let circleSize: Double
    private let circleColor: Color
    private let lineWidth: Double
    private let lineColor: Color
    private let errorColor: Color
    private let shouldDisplayLine: Bool
    private let onPatternComplete: ([Point], PatternLockValidationResult) -> Void
    
    public init(
        state: PatternLockState,
        initialPattern: [Point]? = nil,
        circleSize: Double = 20,
        circleColor: Color = .blue,
        lineWidth: Double = 2,
        lineColor: Color = .blue,
        errorColor: Color = .red,
        shouldDisplayLine: Bool = true,
        onPatternComplete: @escaping ([Point], PatternLockValidationResult) -> Void
    ) {
        self.state = state
        self.circleSize = circleSize
        self.circleColor = circleColor
        self.lineWidth = lineWidth
        self.lineColor = lineColor
        self.errorColor = errorColor
        self.shouldDisplayLine = shouldDisplayLine
        self.onPatternComplete = onPatternComplete
    }
    
    public var body: some View {
        Group {
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)
                ZStack {
                    ForEach(0..<state.dots.count, id: \.self) { row in
                        ForEach(0..<state.dots[row].count, id: \.self) { col in
                            Circle()
                                .fill(getDotColor(for: state.dots[row][col]))
                                .frame(width: circleSize, height: circleSize)
                                .position(
                                    x: geometry.size.width * CGFloat(col + 1) / CGFloat(state.dots.count + 1),
                                    y: geometry.size.height * CGFloat(row + 1) / CGFloat(state.dots.count + 1)
                                )
                                .preference(
                                    key: DotFramePreferenceKey.self,
                                    value: [
                                        DotFramePreference(
                                            point: state.dots[row][col].position,
                                            frame: CGRect(
                                                x: geometry.size.width * CGFloat(col + 1) / CGFloat(state.dots.count + 1) - circleSize/2,
                                                y: geometry.size.height * CGFloat(row + 1) / CGFloat(state.dots.count + 1) - circleSize/2,
                                                width: circleSize,
                                                height: circleSize
                                            )
                                        )
                                    ]
                                )
                        }
                    }
                    
                    if shouldDisplayLine {
                        PatternLineView(
                            selectedDots: state.selectedDots,
                            currentPosition: state.currentPosition,
                            dotFrames: Dictionary(
                                uniqueKeysWithValues: state.dots.flatMap { row in
                                    row.map { dot in (dot.position, dot.frame) }
                                }
                            ),
                            lineWidth: lineWidth,
                            lineColor: state.isShowingError ? errorColor : lineColor
                        )
                    }
                }
                .frame(width: size, height: size)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if !state.isShowingError && state.validationError == nil {
                                handleDrag(at: value.location)
                            }
                        }
                        .onEnded { _ in
                            if !state.isShowingError && state.validationError == nil {
                                handleDragEnd()
                            }
                        }
                )
                .onPreferenceChange(DotFramePreferenceKey.self) { preferences in
                    for preference in preferences {
                        if let row = state.dots.firstIndex(where: { $0.contains(where: { $0.position == preference.point }) }),
                           let col = state.dots[row].firstIndex(where: { $0.position == preference.point }) {
                            state.dots[row][col].frame = preference.frame
                        }
                    }
                }
            }
        }
    }
    
    public func reset() {
        state.reset()
    }
    
    private func getDotColor(for dot: DotState) -> Color {
        if (state.isShowingError || state.validationError != nil) && dot.isSelected {
            return errorColor
        }
        return dot.isSelected ? circleColor : circleColor.opacity(0.75)
    }
    
    private func handleDrag(at position: CGPoint) {
        state.currentPosition = position
        
        // Check for new dot selection
        for row in state.dots {
            for dot in row {
                if dot.frame.contains(position) && !state.selectedDots.contains(dot.position) {
                    // Check if this is the first dot or if it's adjacent to the last selected dot
                    if state.selectedDots.isEmpty ||
                       (state.selectedDots.last?.isAdjacent(to: dot.position) ?? false) {
                        state.selectedDots.append(dot.position)
                        if let row = state.dots.firstIndex(where: { $0.contains(where: { $0.position == dot.position }) }),
                           let col = state.dots[row].firstIndex(where: { $0.position == dot.position }) {
                            state.dots[row][col].isSelected = true
                        }
                        return
                    }
                }
            }
        }
        
        // Backward movement logic remains the same...
        if let lastDot = state.selectedDots.last,
           let secondLastDot = state.selectedDots.dropLast().last {
            let lastDotFrame = state.dots.flatMap({ $0 })
                .first(where: { $0.position == lastDot })?.frame ?? .zero
            let secondLastDotFrame = state.dots.flatMap({ $0 })
                .first(where: { $0.position == secondLastDot })?.frame ?? .zero
            
            let lastDotCenter = CGPoint(x: lastDotFrame.midX, y: lastDotFrame.midY)
            let secondLastDotCenter = CGPoint(x: secondLastDotFrame.midX, y: secondLastDotFrame.midY)
            
            // Calculate vectors
            let patternVector = CGPoint(
                x: lastDotCenter.x - secondLastDotCenter.x,
                y: lastDotCenter.y - secondLastDotCenter.y
            )
            let dragVector = CGPoint(
                x: position.x - secondLastDotCenter.x,
                y: position.y - secondLastDotCenter.y
            )
            
            let angle = abs(angleBetweenVectors(v1: patternVector, v2: dragVector))
            
            let distanceToLast = distance(from: position, to: lastDotCenter)
            let distanceToSecondLast = distance(from: position, to: secondLastDotCenter)
            
            if angle > 150 && distanceToSecondLast < distanceToLast {
                state.selectedDots.removeLast()
                if let row = state.dots.firstIndex(where: { $0.contains(where: { $0.position == lastDot }) }),
                   let col = state.dots[row].firstIndex(where: { $0.position == lastDot }) {
                    state.dots[row][col].isSelected = false
                }
            }
        }
    }
    
    private func angleBetweenVectors(v1: CGPoint, v2: CGPoint) -> CGFloat {
        let dotProduct = v1.x * v2.x + v1.y * v2.y
        let magnitudeProduct = sqrt(v1.x * v1.x + v1.y * v1.y) * sqrt(v2.x * v2.x + v2.y * v2.y)
        
        guard magnitudeProduct != 0 else { return 0 }
        
        let cosAngle = dotProduct / magnitudeProduct
        return acos(min(max(cosAngle, -1), 1)) * 180 / .pi
    }

    private func handleDragEnd() {
        let result = state.validatePattern()
        onPatternComplete(state.selectedDots, result)
        
        if case .failure = result {
            state.showError()
        }
        state.reset()
    }
    
    private func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        let dx = point1.x - point2.x
        let dy = point1.y - point2.y
        return sqrt(dx * dx + dy * dy)
    }
}
