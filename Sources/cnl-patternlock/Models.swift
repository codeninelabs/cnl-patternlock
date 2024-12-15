//
//  models.swift
//  pattrnd
//
//  Created by Kevin Armstrong on 12/13/24.
//
import SwiftUI

public struct Point: Codable, Hashable, Sendable {
    let x: Int
    let y: Int
}

public struct DotState {
    let position: Point
    var isSelected: Bool = false
    var frame: CGRect = .zero
}

public struct DotFramePreference: Equatable, Sendable {
    let point: Point
    let frame: CGRect
}

public struct DotFramePreferenceKey: PreferenceKey {
    static public let defaultValue: [DotFramePreference] = []
    
    static public func reduce(value: inout [DotFramePreference], nextValue: () -> [DotFramePreference]) {
        value.append(contentsOf: nextValue())
    }
}
