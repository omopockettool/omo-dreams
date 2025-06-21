//
//  Item.swift
//  OMO Dreams
//
//  Created by Dennis Chicaiza A on 21/6/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
