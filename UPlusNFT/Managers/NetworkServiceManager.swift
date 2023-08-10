//
//  NetworkServiceManager.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import Foundation

final class NetworkServiceManager {
    static func execute<T: Decodable>(expecting type: T.Type,
                                       request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            throw URLError(.cannotParseResponse)
        }
        if 200..<300 ~= statusCode {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(type.self, from: data)
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

