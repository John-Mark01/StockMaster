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

    
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
//        .onAppear(perform: viewModel.startUpdatingPrices)
    }
}

#Preview {
    ContentView()
}
