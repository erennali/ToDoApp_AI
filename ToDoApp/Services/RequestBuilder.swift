//
//  RequestBuilder.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 7.02.2025.
//

import Foundation

class RequestBuilder {
    func buildRequest(prompt: String, url: URL?, apiKey: String) -> URLRequest? {
        guard let apiURL = url else {
            return nil
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 150
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            return nil
        }
        request.httpBody = jsonData
        return request
    }
}
