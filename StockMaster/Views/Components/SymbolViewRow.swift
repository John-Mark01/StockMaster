//
// SymbolViewRow.swift
// StockMaster
//     
// Created by John-Mark Iliev on 3.12.25
//

import SwiftUI

struct SymbolViewRow: View {
    let symbol: SymbolModel
    
    @State private var animateText: Bool = false
    
    private var formattedPrice: String {
        String(format: "$%.2f", symbol.currentPrice)
    }
    
    private var priceTextColor: Color {
        guard animateText else { return Color.black }
        
        if symbol.priceChange == .up {
            return Color.green
        } else if symbol.priceChange == .down {
            return Color.red
        } else {
            return Color.black
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Text(symbol.name.uppercased())
                .font(.title)
            
            Spacer()
            
            Text(formattedPrice)
                .font(.headline)
                .contentTransition(.numericText(value: 0.2))
                .foregroundStyle(priceTextColor)
                .animation(.linear(duration: 0.2), value: animateText)
            
            if symbol.hasChangedPrice {
                Group {
                    switch symbol.priceChange {
                    case .up:
                        Image(systemName: "arrow.up.right")
                            .font(.headline)
                            .foregroundStyle(Color.green)
                    case .down:
                        Image(systemName: "arrow.down.right")
                            .font(.headline)
                            .foregroundStyle(Color.red)
                    case .neutral:
                        EmptyView()
                    }
                }
                .animation(.spring(duration: 0.4), value: symbol.hasChangedPrice)
            }
        }
        .onChange(of: symbol.hasChangedPrice) { _, _ in
            animateText = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                animateText = false
            }
        }
    }
}

#Preview {
    SymbolViewRow(
        symbol: .init(name: "AAPL", currentPrice: 134.12341)
    )
    .padding()
    .border(.gray)
}
