//
//  models.swift
//  pattrnd
//
//  Created by Kevin Armstrong on 12/13/24.
//
import SwiftUI

public struct Point: Codable, Hashable, Sendable {
    public let x: Int
    public let y: Int
}

public struct DotState {
    public let position: Point
    public var isSelected: Bool = false
    public var frame: CGRect = .zero
}

public struct DotFramePreference: Equatable, Sendable {
    public let point: Point
    public let frame: CGRect
}

public struct DotFramePreferenceKey: PreferenceKey {
    static public let defaultValue: [DotFramePreference] = []
    
    static public func reduce(value: inout [DotFramePreference], nextValue: () -> [DotFramePreference]) {
        value.append(contentsOf: nextValue())
    }
}
