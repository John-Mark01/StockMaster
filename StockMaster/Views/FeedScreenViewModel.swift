//
//  ContentViewModel.swift
//  StockMaster
//
//  Created by John-Mark Iliev on 3.12.25.
//

import Foundation
import Combine

final class FeedScreenViewModel: ObservableObject {
    
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
        populateSymbols()
        connectToWebSocket()
        startUpdatingPrices()
    }
    
    func connectToWebSocket() {
        subscribeToWebSocket()
        webSocket.connect()
    }
    
    func disconnectFromWebSocket() {
        webSocket.disconnect()
        self.sendMessageTask = nil
    }
    
    private func subscribeToWebSocket() {
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
    
    private func populateSymbols() {
        self.symbols = [
            .init(
                name: "AAPL",
                currentPrice: 140.12,
                oldPrice: nil,
                description: "Apple Inc. designs and manufactures consumer electronics including iPhone, iPad, Mac computers, and Apple Watch. The company also operates services like the App Store, Apple Music, iCloud, and Apple Pay. Apple is known for its innovative hardware, software integration, and strong brand loyalty. It's one of the world's most valuable technology companies."
            ),
            .init(
                name: "MSFT",
                currentPrice: 290.52,
                oldPrice: nil,
                description: "Microsoft Corporation develops software, cloud services, and devices worldwide. The company's products include Windows operating systems, Office productivity suite, Azure cloud platform, and Xbox gaming consoles. Microsoft is a leader in enterprise software and cloud computing infrastructure. It also owns LinkedIn and invests heavily in artificial intelligence technologies."
            ),
            .init(
                name: "GOOGL",
                currentPrice: 2800.01,
                oldPrice: nil,
                description: "Alphabet Inc. is the parent company of Google and operates the world's dominant search engine. The company generates most revenue through digital advertising on Google and YouTube. Alphabet also provides cloud computing services, consumer hardware like Pixel phones, and invests in emerging technologies. It leads in online search, video streaming, and digital advertising markets."
            ),
            .init(
                name: "AMZN",
                currentPrice: 3400.90,
                oldPrice: nil,
                description: "Amazon.com Inc. operates the largest online retail marketplace and cloud computing platform globally. Amazon Web Services (AWS) provides cloud infrastructure to businesses and is a major profit center. The company offers Prime subscription services, produces consumer electronics like Kindle and Echo, and operates streaming platforms. Amazon continues to expand into logistics, healthcare, and artificial intelligence."
            ),
            .init(
                name: "META",
                currentPrice: 231.14,
                oldPrice: nil,
                description: "Meta Platforms Inc. owns and operates social media platforms including Facebook, Instagram, WhatsApp, and Messenger. The company earns revenue primarily through targeted digital advertising across its family of apps. Meta serves billions of users globally and is investing heavily in virtual reality and metaverse technologies. It's transitioning from a social media company to a metaverse-focused technology leader."
            ),
            .init(
                name: "TSLA",
                currentPrice: 709.78,
                oldPrice: nil,
                description: "Tesla Inc. manufactures electric vehicles and energy storage solutions worldwide. The company produces popular EV models including Model S, Model 3, Model X, and Model Y. Tesla also develops autonomous driving technology and solar energy products. Led by Elon Musk, it's pioneering the transition to sustainable transportation and energy."
            ),
            .init(
                name: "NFLX",
                currentPrice: 512.00,
                oldPrice: nil,
                description: "Netflix Inc. is a leading streaming entertainment platform offering movies, TV shows, and original content. The service operates on a subscription model with over 200 million global subscribers. Netflix invests billions in original programming and has transformed how people consume entertainment. It faces growing competition from Disney+, HBO Max, and other streaming services."
            ),
            .init(
                name: "NVDA",
                currentPrice: 366.10,
                oldPrice: nil,
                description: "NVIDIA Corporation designs and manufactures graphics processing units (GPUs) for gaming, AI, and data centers. The company's chips power advanced artificial intelligence systems, autonomous vehicles, and cryptocurrency mining. NVIDIA dominates the GPU market and is essential to modern AI and machine learning infrastructure. Its technology is critical for gaming, scientific research, and enterprise computing."
            ),
            .init(
                name: "NTAP",
                currentPrice: 127.07,
                oldPrice: nil,
                description: "NetApp Inc. provides data management and storage solutions for enterprise customers. The company offers cloud data services, storage systems, and data management software. NetApp helps organizations manage and protect their data across hybrid cloud environments. It competes in enterprise storage and cloud data management markets."
            ),
            .init(
                name: "MA",
                currentPrice: 154.10,
                oldPrice: nil,
                description: "Mastercard Inc. operates a global payment processing network connecting consumers, merchants, and financial institutions. The company facilitates electronic payments and provides fraud prevention and security services. Mastercard earns revenue from transaction processing fees on billions of payments worldwide. It's one of the largest payment networks alongside Visa."
            ),
            .init(
                name: "WDC",
                currentPrice: 180.00,
                oldPrice: nil,
                description: "Western Digital Corporation manufactures data storage devices and solutions for consumers and enterprises. The company produces hard disk drives (HDDs), solid-state drives (SSDs), and storage systems. Western Digital serves cloud data centers, personal computers, gaming consoles, and surveillance systems. It's a major player in the global data storage industry."
            ),
            .init(
                name: "SEG",
                currentPrice: 130.00,
                oldPrice: nil,
                description: "Seagate Technology Holdings manufactures hard disk drives and data storage solutions globally. The company provides storage products for enterprise data centers, cloud computing, and consumer electronics. Seagate focuses on high-capacity storage for mass data storage needs. It competes with Western Digital in the traditional HDD market."
            ),
            .init(
                name: "TSM",
                currentPrice: 912.11,
                oldPrice: nil,
                description: "Taiwan Semiconductor Manufacturing Company (TSMC) is the world's largest dedicated semiconductor foundry. The company manufactures chips for leading technology companies including Apple, NVIDIA, and AMD. TSMC leads in advanced chip manufacturing processes and is critical to the global semiconductor supply chain. It's essential to producing cutting-edge processors and AI chips."
            ),
            .init(
                name: "ORCL",
                currentPrice: 200.00,
                oldPrice: nil,
                description: "Oracle Corporation provides database software, cloud computing solutions, and enterprise software products. The company's database technology powers critical business applications for organizations worldwide. Oracle offers cloud infrastructure, enterprise resource planning (ERP), and customer relationship management (CRM) solutions. It's a major player in enterprise software and cloud services."
            ),
            .init(
                name: "HPE",
                currentPrice: 123.12,
                oldPrice: nil,
                description: "Hewlett Packard Enterprise provides enterprise IT infrastructure, software, and services. The company offers servers, storage systems, networking equipment, and hybrid cloud solutions. HPE focuses on helping businesses modernize their data centers and adopt cloud computing. It serves large enterprises and government organizations globally."
            ),
            .init(
                name: "CPQ",
                currentPrice: 159.10,
                oldPrice: nil,
                description: "Compaq (historical ticker) was a personal computer company that pioneered the PC-compatible market. The company was known for portable computers and desktop PCs during the 1980s and 1990s. Compaq was acquired by Hewlett-Packard in 2002 and integrated into HP's product line. The brand legacy represents innovation in personal computing history."
            ),
            .init(
                name: "PLTR",
                currentPrice: 180.00,
                oldPrice: nil,
                description: "Palantir Technologies develops software platforms for data integration and analysis. The company serves government agencies, defense organizations, and commercial enterprises with big data analytics. Palantir's platforms help organizations make data-driven decisions and identify patterns in complex datasets. It's known for its work in national security and enterprise data analytics."
            ),
            .init(
                name: "JNJ",
                currentPrice: 130.00,
                oldPrice: nil,
                description: "Johnson & Johnson is a global healthcare company developing pharmaceuticals, medical devices, and consumer health products. The company produces well-known consumer brands like Band-Aid, Tylenol, and Neutrogena. J&J invests heavily in pharmaceutical research and medical technology innovation. It's one of the world's largest and most diversified healthcare companies."
            ),
            .init(
                name: "WMT",
                currentPrice: 90.19,
                oldPrice: nil,
                description: "Walmart Inc. operates the world's largest retail chain with thousands of stores globally. The company offers groceries, general merchandise, and e-commerce through Walmart.com. Walmart is known for its low prices, efficient supply chain, and growing digital commerce presence. It competes with Amazon in both physical retail and online shopping."
            ),
            .init(
                name: "SNDK",
                currentPrice: 211.00,
                oldPrice: nil,
                description: "SanDisk (historical ticker) was a leading manufacturer of flash memory storage products. The company produced SD cards, USB flash drives, and solid-state drives for consumers and enterprises. SanDisk was acquired by Western Digital in 2016 and integrated into WDC's product portfolio. The brand pioneered portable flash storage technology."
            )
        ]
    }
}
