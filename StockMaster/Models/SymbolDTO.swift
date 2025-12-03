//
//  SymbolDTO.swift
//  StockMaster
//
//  Created by John-Mark Iliev on 2.12.25.
//

import Foundation

struct SymbolDTO: Codable, Equatable {
    let name: String
    var currentPrice: Double
    var newPrice: Double?
}

struct SymbolModel: Identifiable, Equatable {
    let id = UUID()
    let name: String
    var currentPrice: Double
    var oldPrice: Double?
    
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

}
