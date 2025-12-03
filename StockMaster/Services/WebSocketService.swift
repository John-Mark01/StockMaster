//
//  WebSocketService.swift
//  StockMaster
//
//  Created by John-Mark Iliev on 2.12.25.
//

import Foundation
import Combine

protocol WebSocketService {
    
    var publisher: AnyPublisher<Data, Error> { get }
    var connectionPublisher: AnyPublisher<ConnectionStatus, Never> { get }
    
    func connect() -> Void
    func disconnect() -> Void
    func sendMessage(_ message: String) -> Void
    func recieveMessage() async throws -> Void
}

final class WebSocketServiceImpl: WebSocketService {
    
    var publisher: AnyPublisher<Data, Error> {
        dataSubject.eraseToAnyPublisher()
    }
    
    var connectionPublisher: AnyPublisher<ConnectionStatus, Never> {
        connectionSubject.eraseToAnyPublisher()
    }
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let dataSubject = PassthroughSubject<Data, Error>()
    private let connectionSubject = CurrentValueSubject<ConnectionStatus, Never>(.idle)
    private let urlString: String = "wss://ws.postman-echo.com/raw"
    
    func connect() {
        guard let url = URL(string: urlString) else { return }
        
        connectionSubject.send(.idle)
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        
        Task {
            try await recieveMessage()
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        connectionSubject.send(.disconnected)
        
        print("🔴 Disconnected from WebSocket\n")
    }
    
    func sendMessage(_ message: String) {
        let msg = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(msg) { [weak self] error in
            if let error = error {
                print("❌ WebSocket sending error: \(error)")
                self?.disconnect()
            } else {
                print("✅ Message: \(message) sent successfully!")
            }
        }
    }
    
    func recieveMessage() async throws {
        var isFirstMessage = true
        
        while let task = webSocketTask {
            do {
                let message = try await task.receive()
                
                if isFirstMessage {
                    connectionSubject.send(.connected)
                    isFirstMessage = false
                    print("🟢 Connected to WebSocket\n")
                }
                
                switch message {
                case let .string(string):
                    dataSubject.send(string.data(using: .utf8) ?? Data())
                case let .data(data):
                    dataSubject.send(data)
                @unknown default:
                    break
                }
            } catch {
                self.disconnect()
                dataSubject.send(completion: .failure(error))
                throw error
            }
        }
    }
    
    
}

enum ConnectionStatus: Equatable {
    case idle
    case connected
    case disconnected
}
