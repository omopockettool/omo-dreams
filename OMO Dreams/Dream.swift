//
//  Dream.swift
//  OMO Dreams
//
//  Created by Dennis Chicaiza A on 21/6/25.
//

import Foundation
import SwiftData

@Model
final class Dream {
    @Attribute(.unique) var id: String
    var dream_date: Date
    var dream_text: String
    var isLucid: Bool
    @Relationship(deleteRule: .cascade) var dreamPatterns: [DreamPattern] = []
    
    init(id: String = UUID().uuidString, dream_date: Date, dream_text: String, isLucid: Bool = false) {
        self.id = id
        self.dream_date = dream_date
        self.dream_text = dream_text
        self.isLucid = isLucid
    }
}
