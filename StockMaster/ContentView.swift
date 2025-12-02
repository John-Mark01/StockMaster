//
//  ContentView.swift
//  StockMaster
//
//  Created by John-Mark Iliev on 2.12.25.
//

import SwiftUI
import Combine

struct ContentView: View {
    let webSocketService = WebSocketServiceImpl()
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            webSocketService.sendMessage("This is a test!")
            webSocketService.publisher
                .receive(on: RunLoop.main)
                .throttle(for: 0.2, scheduler: RunLoop.main, latest: true)
                .sink(receiveCompletion: { print($0) }, receiveValue: { print($0)}
                )
                .store(in: &cancellables)
        }
    }
}

#Preview {
    ContentView()
}
