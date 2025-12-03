//
//  SymbolDetailsScreen.swift
//  StockMaster
//
//  Created by John-Mark Iliev on 3.12.25.
//

import SwiftUI

struct SymbolDetailsScreen: View {
    var symbol: SymbolModel
    
    var body: some View {
        VStack {
            
            SymbolViewRow(symbol: symbol)
            Spacer()
        }
        .padding()
        .navigationTitle(symbol.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        SymbolDetailsScreen(
            symbol: .init(
                name: "AAPL",
                currentPrice: 14.23,
                oldPrice: 90.12
            )
        )
    }
}
