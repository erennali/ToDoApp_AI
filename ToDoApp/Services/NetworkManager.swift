//
//  NetworkManager.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 7.02.2025.
//

import Foundation

class NetworkManager {
    func sendRequest(_ request: URLRequest) async
    throws -> Data {
        let (responseData, _) = try await URLSession.shared.data(for: request)
        return responseData
    }
}
