//
//  ContentView.swift
//  StockMaster
//
//  Created by John-Mark Iliev on 2.12.25.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel(
        webSocket: WebSocketServiceImpl()
    )
    
    var body: some View {
        List {
            ForEach(viewModel.symbols.sorted(by: { $0.currentPrice > $1.currentPrice }), id: \.name) { symbol in
                SymbolViewRow(symbol: symbol)
            }
        }
//        .onAppear(perform: viewModel.startUpdatingPrices)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(viewModel.isConnectedCondition ? "Stop" : "Start") {
                    if viewModel.isConnectedCondition {
                        viewModel.disconnectFromWebSocket()
                        viewModel.isConnectedCondition = false
                    } else {
                        viewModel.connectToWebSocket()
                        viewModel.startUpdatingPrices()
                        viewModel.isConnectedCondition = true
                    }
                }
                .buttonStyle(.bordered)
                .tint(viewModel.isConnectedCondition ? Color.red : Color.green)
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Circle()
                    .fill(viewModel.isConnectedCondition ? Color.green : Color.red)
                    .frame(width: 30, height: 30)
            }
        }
    }
}

struct SymbolViewRow: View {
    let symbol: SymbolDTO
    
    private var formattedPrice: String {
        String(format: "$%.2f", symbol.currentPrice)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Text(symbol.name.uppercased())
                .font(.title)
            
            Spacer()
            
            Text(formattedPrice)
            
            Image(systemName: "arrow.up.right")
                .font(.headline)
                .foregroundStyle(Color.green)
            
            Image(systemName: "arrow.down.right")
                .font(.headline)
                .foregroundStyle(Color.red)
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
