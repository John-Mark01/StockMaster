//
//  SymbolModel.swift
//  StockMaster
//
//  Created by John-Mark Iliev on 3.12.25.
//

import Foundation

struct SymbolModel: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    var currentPrice: Double
    var oldPrice: Double?
    var desctrption: String?
    
    var priceChange: SymbolPriceChange {
        guard let oldPrice else { return .neutral }
        
        if currentPrice > oldPrice {
            return .up
        } else if currentPrice < oldPrice {
            return .down
        } else {
            return .neutral
        }
    }
    
    var hasChangedPrice: Bool {
        oldPrice != nil && oldPrice != currentPrice
    }
    
    var imageName: String {
        switch priceChange {
        case .up:
            return "arrow.up.right"
        case .down:
            return "arrow.down.right"
        case .neutral:
            return "arrow.2.circlepath.circle"
        }
    }
}
