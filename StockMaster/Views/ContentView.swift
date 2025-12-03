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
            ForEach(viewModel.symbols.sorted(by: { $0.currentPrice > $1.currentPrice }), id: \.id) { symbol in
                SymbolViewRow(symbol: symbol)
            }
        }
        .animation(.easeIn(duration: 1.2), value: viewModel.elementWillChange)
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

#Preview {
    NavigationStack {
        ContentView()
    }
}
