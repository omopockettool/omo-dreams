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
    var dream_date: Date
    var dream_text: String
    var dream_patterns: String
    
    init(dream_date: Date, dream_text: String, dream_patterns: String) {
        self.dream_date = dream_date
        self.dream_text = dream_text
        self.dream_patterns = dream_patterns
    }
}
