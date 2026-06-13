//
//  Item.swift
//  WCS-Insight
//
//  Created by Christopher Appiah-Thompson  on 14/6/2026.
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
