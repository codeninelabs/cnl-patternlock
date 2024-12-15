//
//  PatternLineView.swift
//  pattrnd
//
//  Created by Kevin Armstrong on 12/14/24.
//
import SwiftUI

public struct PatternLineView: View {
    let selectedDots: [Point]
    let currentPosition: CGPoint?
    let dotFrames: [Point: CGRect]
    let lineWidth: Double
    let lineColor: Color
    
    public var body: some View {
        Canvas { context, size in
            for i in 0..<selectedDots.count {
                let currentDot = selectedDots[i]
                let currentFrame = dotFrames[currentDot] ?? .zero
                let currentCenter = CGPoint(x: currentFrame.midX, y: currentFrame.midY)
                
                if i < selectedDots.count - 1 {
                    let nextDot = selectedDots[i + 1]
                    let nextFrame = dotFrames[nextDot] ?? .zero
                    let nextCenter = CGPoint(x: nextFrame.midX, y: nextFrame.midY)
                    
                    var path = Path()
                    path.move(to: currentCenter)
                    path.addLine(to: nextCenter)
                    context.stroke(
                        path,
                        with: .color(lineColor),
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                } else if let currentPosition = currentPosition {
                    var path = Path()
                    path.move(to: currentCenter)
                    path.addLine(to: currentPosition)
                    context.stroke(
                        path,
                        with: .color(lineColor),
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                }
            }
        }
    }
}
