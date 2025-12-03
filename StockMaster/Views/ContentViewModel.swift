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
    private var sendMessageTask: Task<Void, Error>?
    
    @Published var symbols: [SymbolModel] = [] {
        willSet { elementWillChange = true}
    }

    @Published var elementWillChange: Bool = false
    @Published var connectionStatus: ConnectionStatus = .idle
    
    
    init(webSocket: WebSocketService) {
        self.webSocket = webSocket
        self.symbols = [
            .init(name: "AAPL", currentPrice: 140.12, oldPrice: nil),
            .init(name: "MSFT", currentPrice: 290.52, oldPrice: nil),
            .init(name: "GOOGL", currentPrice: 2800.01, oldPrice: nil),
            .init(name: "AMZN", currentPrice: 3400.90, oldPrice: nil),
            .init(name: "META", currentPrice: 231.14, oldPrice: nil),
            .init(name: "TSLA", currentPrice: 709.78, oldPrice: nil),
            .init(name: "NFLX", currentPrice: 512.00, oldPrice: nil),
            .init(name: "NVDA", currentPrice: 366.10, oldPrice: nil),
            .init(name: "NTAP", currentPrice: 127.07, oldPrice: nil),
            .init(name: "MA", currentPrice: 154.10, oldPrice: nil),
            .init(name: "WDC", currentPrice: 180.00, oldPrice: nil),
            .init(name: "SEG", currentPrice: 130.00, oldPrice: nil),
            .init(name: "TSM", currentPrice: 912.11, oldPrice: nil),
            .init(name: "ORCL", currentPrice: 200.00, oldPrice: nil),
            .init(name: "HPE", currentPrice: 123.12, oldPrice: nil),
            .init(name: "CPQ", currentPrice: 159.10, oldPrice: nil),
            .init(name: "PLTR", currentPrice: 180.00, oldPrice: nil),
            .init(name: "JNJ", currentPrice: 130.00, oldPrice: nil),
            .init(name: "WMT", currentPrice: 90.19, oldPrice: nil),
            .init(name: "SNDK", currentPrice: 211.00, oldPrice: nil)
        ]
        
        connectToWebSocket()
        subscribeToWebSocket()
    }
    
    func connectToWebSocket() {
        webSocket.connect()
    }
    
    func disconnectFromWebSocket() {
        webSocket.disconnect()
        self.sendMessageTask = nil
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
        
        webSocket.connectionPublisher
            .receive(on: RunLoop.main)
            .assign(to: &$connectionStatus)
    }
    
    func startUpdatingPrices() {
        self.sendMessageTask = Task {
            while connectionStatus != .disconnected {
                for symbol in symbols {
                    
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    let newSymbol = SymbolDTO(
                        name: symbol.name,
                        currentPrice: symbol.currentPrice,
                        newPrice: generateRandomPrice()
                    )
                    guard let symbolData = convertSymbolToData(newSymbol),
                          let jsonString = String(data: symbolData, encoding: .utf8) else { return }
                    webSocket.sendMessage(jsonString)
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
        if let index = self.symbols.firstIndex(where: {$0.name == symbol.name}) {
            self.symbols[index].oldPrice = symbol.currentPrice
            self.symbols[index].currentPrice = symbol.newPrice ?? 0
        }
    }
}
