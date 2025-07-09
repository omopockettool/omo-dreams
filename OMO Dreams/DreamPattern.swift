//
//  DreamPattern.swift
//  OMO Dreams
//
//  Created by Dennis Chicaiza A on 21/6/25.
//

import Foundation
import SwiftData

@Model
final class DreamPattern {
    var dreamId: String
    var isRecognitionClue: Bool
    @Relationship var pattern: Pattern?
    @Relationship var dream: Dream?
    
    init(dreamId: String, pattern: Pattern, isRecognitionClue: Bool = false) {
        self.dreamId = dreamId
        self.pattern = pattern
        self.isRecognitionClue = isRecognitionClue
    }
} 