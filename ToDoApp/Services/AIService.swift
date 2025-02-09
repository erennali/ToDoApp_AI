//
//  AIService.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 7.02.2025.
//

import Foundation

class AIService {
    
    private let networkManager = NetworkManager()
    private let requestBuilder = RequestBuilder()
    private let errorMesage = "Error: Unable to generative AI response"
    private let apiKeyMissingMessage = "API anahtarı bulunamadı. Lütfen OpenAI API anahtarınızı ayarlayın."
    private let url = URL(string: "https://api.openai.com/v1/chat/completions")
    
    func getAIResponse(prompt: String) async -> String {
        guard let apiKey = EnvironmentManager.apiKey else {
            return apiKeyMissingMessage
        }
        
        guard let request = requestBuilder.buildRequest(prompt: "Bana 5 adımda \(prompt) öğrenmek için öğretici ve sıralı bir yapılacaklar listesi oluştur. Her adımda, gerekli araçlar, kaynak önerileri ve başlangıç noktaları ver ve bunların ortalama kaç hafta süreceği aralığı da yaz ve yanıtını 2000 karakteri geçmeyecek şekilde özetle ve sadece Adımları yazdır , en son bir öneride sakın bulunma", url: url, apiKey: apiKey) else {
            print("[Error] Failed to build request")
            return errorMesage
        }
        
        do {
            let data = try await networkManager.sendRequest(request)
            return decodeResponse(data)
        }catch {
            print("[Error] Failed to send request: \(error.localizedDescription)")
            return errorMesage
        }
    }
    
    
    private func decodeResponse(_ data: Data) -> String {
        do {
            // API yanıtını kontrol et
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            let aiResponse = try decoder.decode(AIResponse.self, from: data)
            
            // Başarılı yanıt
            print("[Success] Decoded response successfully")
            print("[Message] \(aiResponse.choices.first?.message.content ?? "No content")")
            
            return aiResponse.choices.first?.message.content ?? "No Response Found"
            
        } catch {
            print("[Error] Failed to decode response: \(error.localizedDescription)")
            print("[Error] Detailed error: \(error)")
            
            // Ham JSON'u kontrol et
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("[Debug] Raw JSON structure: \(String(describing: json))")
                
                // API hata mesajını kontrol et
                if let errorMessage = json?["error"] as? [String: Any],
                   let message = errorMessage["message"] as? String {
                    print("[Debug] API Error Message: \(message)")
                    return "API Error: \(message)"
                }
            } catch {
                print("[Debug] Failed to parse raw JSON: \(error)")
            }
            
            return errorMesage
        }
    }
    
    
}
