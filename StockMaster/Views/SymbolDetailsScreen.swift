//
//  SymbolDetailsScreen.swift
//  StockMaster
//
//  Created by John-Mark Iliev on 3.12.25.
//

import SwiftUI

struct SymbolDetailsScreen: View {
    var symbol: SymbolModel
    
    private var percentageChange: Double {
        guard let oldPrice = symbol.oldPrice else { return 0 }
        
        return ((symbol.currentPrice - oldPrice) / oldPrice) * 100
    }
    
    private var difference: Double {
        guard let oldPrice = symbol.oldPrice else { return 0 }
        return symbol.currentPrice - oldPrice
    }
    
    private var percentageColor: Color {
        if percentageChange < 0 {
            return .red
        } else {
            return .green
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack(alignment: .top) {
                Text(symbol.name)
                    .font(.title)
                
                Spacer()
                
                Text("$\(symbol.currentPrice, specifier: "%.2f")")
                    .font(.title2)
                    .bold()
                
                Group {
                    Text("\(difference, specifier: "%.2f")")
                    
                    Image(systemName: symbol.imageName)
                }
                .font(.headline)
                .foregroundStyle(percentageColor)
            }
            
            Text(symbol.desctrption ?? "")
                .font(.title3)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .navigationTitle(symbol.name)
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        SymbolDetailsScreen(
            symbol: .init(
                name: "AAPL",
                currentPrice: 144.23,
                oldPrice: 90.12,
                desctrption: "This is a description for Apple Inc. symbol. So long as this is a description, it should be good enough."
            )
        )
    }
}
