//
//  WebSocketAdapter.swift
//  StockMaster
//
//  Created by John-Mark Iliev on 2.12.25.
//

import Foundation
import Combine

class WebSocketAdapter: WebSocketService {
    
    let webSocket: WebSocketService
    init(webSocket: WebSocketService) {
        self.webSocket = webSocket
    }
    
    var publisher: AnyPublisher<Data, Error> {
        webSocket.publisher
    }
    
    func connect() {
        webSocket.connect()
    }
    
    func disconnect() {
        webSocket.disconnect()
    }
    
    func sendMessage(_ message: Data) {
        Task {
            while true {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                webSocket.sendMessage(message)
            }
        }
    }
    
    func recieveMessage() async throws {
        try await webSocket.recieveMessage()
    }
    
    
    private func generateRandomSymbolMessage() -> String {
        let stocks: [String] = [
            "GOOGL",
            "AAPL",
            "MSFT",
            "AMZN",
            "FB"
        ]
        
        return stocks.randomElement()?.uppercased() ?? "N/A"
    }
}
