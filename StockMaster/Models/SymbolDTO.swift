//
//  SymbolDTO.swift
//  StockMaster
//
//  Created by John-Mark Iliev on 2.12.25.
//

import Foundation

struct SymbolDTO: Codable, Equatable {
    let name: String
    let currentPrice: Double
    let newPrice: Double?
}
