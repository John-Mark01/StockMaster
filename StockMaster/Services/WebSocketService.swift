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
    func recieveMessage() async -> Void
}

final class WebSocketServiceImpl: WebSocketService {
    
    var publisher: AnyPublisher<Data, Error> {
        dataSubject.eraseToAnyPublisher()
    }
    
    var connectionPublisher: AnyPublisher<ConnectionStatus, Never> {
        connectionSubject.eraseToAnyPublisher()
    }
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var receiveTask: Task<Void, Never>?
    private let dataSubject = PassthroughSubject<Data, Error>()
    private let connectionSubject = CurrentValueSubject<ConnectionStatus, Never>(.idle)
    private let urlString: String = "wss://ws.postman-echo.com/raw"
    
    func connect() {
        //cancel task explicitly if existing
        if webSocketTask != nil {
            disconnect()
        }
        
        guard let url = URL(string: urlString) else { return }
        
        connectionSubject.send(.idle)
        
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveTask = Task { [weak self] in
            await self?.recieveMessage()
        }
    }
    
    func disconnect() {
        receiveTask?.cancel()
        receiveTask = nil
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        connectionSubject.send(.disconnected)
        print("🔴 Disconnected from WebSocket\n")
    }
    
    func sendMessage(_ message: String) {
        guard let task = webSocketTask else {
            return
        }
        
        let msg = URLSessionWebSocketTask.Message.string(message)
        task.send(msg) { error in
            if let error = error {
                print("❌ Send error: \(error)")
            } else {
                print("✅ Message: \(message) sent successfully!")
            }
        }
    }
    
    func recieveMessage() async {
        var isFirstMessage = true
        
        while !Task.isCancelled {
            guard let task = webSocketTask else {
                break
            }
            
            do {
                let message = try await task.receive()
                
                if isFirstMessage {
                    connectionSubject.send(.connected)
                    isFirstMessage = false
                    print("🟢 Connected to WebSocket\n")
                }
                
                switch message {
                case .string(let string):
                    if let data = string.data(using: .utf8) {
                        dataSubject.send(data)
                    }
                case .data(let data):
                    dataSubject.send(data)
                @unknown default:
                    break
                }
                
            } catch {
                if !Task.isCancelled {
                    dataSubject.send(completion: .failure(error))
                }
                //break out of loop, if error occurs
                break
            }
        }
    }
}

enum ConnectionStatus: Equatable {
    case idle
    case connected
    case disconnected
}
