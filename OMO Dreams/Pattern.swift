//
//  Pattern.swift
//  OMO Dreams
//
//  Created by Dennis Chicaiza A on 21/6/25.
//

import Foundation
import SwiftData

@Model
final class Pattern {
    @Attribute(.unique) var label: String
    var category: String
    @Relationship(deleteRule: .cascade) var dreamPatterns: [DreamPattern] = []
    
    init(label: String, category: String) {
        self.label = label
        self.category = category
    }
}

enum PatternCategory: String, CaseIterable {
    case action = "action"
    case place = "place"
    case character = "character"
    case object = "object"
    case emotion = "emotion"
    case color = "color"
    case sound = "sound"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .action: return "Acción"
        case .place: return "Lugar"
        case .character: return "Personaje"
        case .object: return "Objeto"
        case .emotion: return "Emoción"
        case .color: return "Color"
        case .sound: return "Sonido"
        case .other: return "Otro"
        }
    }
} 