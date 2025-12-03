//
//  ContentView.swift
//  StockMaster
//
//  Created by John-Mark Iliev on 2.12.25.
//

import SwiftUI

struct FeedScreen: View {
    @StateObject private var viewModel = FeedScreenViewModel(
        webSocket: WebSocketServiceImpl()
    )
    
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                ForEach(viewModel.symbols.sorted(by: { $0.currentPrice > $1.currentPrice }), id: \.id) { symbol in
                    
                    SymbolViewRow(symbol: symbol)
                        .onTapGesture {
                            navigationPath.append(symbol)
                        }
                }
            }
            .navigationDestination(for: SymbolModel.self) { symbol in
                SymbolDetailsScreen(symbol: symbol)
            }
            .animation(.easeIn(duration: 1.2), value: viewModel.elementWillChange)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(viewModel.connectionStatus == .connected ? "Stop" : "Start") {
                        if viewModel.connectionStatus == .connected {
                            viewModel.disconnectFromWebSocket()
                        } else {
                            viewModel.connectToWebSocket()
                            viewModel.startUpdatingPrices()
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(viewModel.connectionStatus == .connected ? Color.red : Color.green)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.connectionStatus == .idle {
                        ProgressView()
                    } else {
                        Circle()
                            .fill(viewModel.connectionStatus == .connected ? Color.green : Color.red)
                            .frame(width: 30, height: 30)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FeedScreen()
    }
}

