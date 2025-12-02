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
    
    func connect() -> Void
    func disconnect() -> Void
    func sendMessage(_ message: String) -> Void
    func recieveMessage() async throws -> Void
}

final class WebSocketServiceImpl: WebSocketService {
    
    var publisher: AnyPublisher<Data, Error> {
        dataSubject.eraseToAnyPublisher()
    }
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let dataSubject = PassthroughSubject<Data, Error>()
    private let urlString: String = "wss://ws.postman-echo.com/raw"
    
    init() {
        connect()
    }
    
    func connect() {
        guard let url = URL(string: urlString) else { return }
        
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        
        Task {
            while true {
                try await recieveMessage()
            }
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    func sendMessage(_ message: String) {
        let msg = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(msg) { error in
            if let error = error {
                print("❌ WebSocket sending error: \(error)")
            } else {
                print("✅ Message: \(message) sent successfully!")
            }
        }
    }
    
    func recieveMessage() async throws {
        guard let webSocketTask else { return }
        do {
            let message = try await webSocketTask.receive()
            switch message {
            case let .string(string):
                dataSubject.send(string.data(using: .utf8) ?? Data())
            case let .data(data):
                dataSubject.send(data)
            @unknown default:
                break
            }
        } catch {
            dataSubject.send(completion: .failure(error))
            throw error
        }
    }
    
    
}
