//
//  ContentViewModel.swift
//  StockMaster
//
//  Created by John-Mark Iliev on 3.12.25.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {
    
    private let webSocket: WebSocketService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var symbols: [SymbolDTO] = []
    
    
    init(webSocket: WebSocketService) {
        self.webSocket = webSocket
        self.symbols = [
            .init(name: "AAPL", currentPrice: 140.00, newPrice: nil),
            .init(name: "MSFT", currentPrice: 290.00, newPrice: nil),
            .init(name: "GOOGL", currentPrice: 2800.00, newPrice: nil),
            .init(name: "AMZN", currentPrice: 3400.00, newPrice: nil),
            .init(name: "FB", currentPrice: 230.00, newPrice: nil),
            .init(name: "TSLA", currentPrice: 700.00, newPrice: nil),
            .init(name: "NFLX", currentPrice: 500.00, newPrice: nil),
            .init(name: "HPE", currentPrice: 300.00, newPrice: nil),
            .init(name: "NTAP", currentPrice: 120.00, newPrice: nil),
            .init(name: "CPQ", currentPrice: 150.00, newPrice: nil),
            .init(name: "WDC", currentPrice: 180.00, newPrice: nil),
            .init(name: "SEG", currentPrice: 130.00, newPrice: nil),
            .init(name: "HPE", currentPrice: 300.00, newPrice: nil),
            .init(name: "SNDK", currentPrice: 200.00, newPrice: nil),
            .init(name: "HPE", currentPrice: 300.00, newPrice: nil),
            .init(name: "CPQ", currentPrice: 150.00, newPrice: nil),
            .init(name: "WDC", currentPrice: 180.00, newPrice: nil),
            .init(name: "SEG", currentPrice: 130.00, newPrice: nil),
            .init(name: "HPE", currentPrice: 300.00, newPrice: nil),
            .init(name: "SNDK", currentPrice: 200.00, newPrice: nil)
        ]
        
        connectToWebSocket()
        subscribeToWebSocket()
    }
    
    func connectToWebSocket() {
        webSocket.connect()
    }
    
    func subscribeToWebSocket() {
        webSocket.publisher
            .receive(on: RunLoop.main)
            .throttle(for: 0.2, scheduler: RunLoop.main, latest: true)
        
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let erorr):
                        self.webSocket.disconnect()
                        print("Error in subscriber: \(erorr.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] data in
                    if let updatedSymbol = self?.decodeSymbolFromData(data) {
                        self?.updateSymbolInStore(updatedSymbol)
                        print("recievedValue: \(updatedSymbol.newPrice ?? 0)")
                    }
                }
            )
            .store(in: &cancellables)
        
    }
    
    func startUpdatingPrices() {
        
        Task {
            while true {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                //                symbols.forEach { symbol in
                //                }
                if let symbol = symbols.randomElement() {
                    let newSymbol = SymbolDTO(
                        name: symbol.name,
                        currentPrice: symbol.currentPrice,
                        newPrice: generateRandomPrice()
                    )
                    guard let symbolData = convertSymbolToData(newSymbol) else { return }
                    webSocket.sendMessage(symbolData)
                }
                
            }
        }
    }
    
    private func generateRandomPrice() -> Double {
        Double.random(in: 0.1...1000)
    }
    
    private func convertSymbolToData(_ symbol: SymbolDTO) -> Data? {
        try? JSONEncoder().encode(symbol)
    }
    
    private func decodeSymbolFromData(_ data: Data) -> SymbolDTO? {
        try? JSONDecoder().decode(SymbolDTO.self, from: data)
    }
    
    private func updateSymbolInStore(_ symbol: SymbolDTO) {
        if let index = self.symbols.firstIndex(of: symbol) {
            self.symbols[index] = symbol
        }
    }
}
