//
//  AIResponse.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 7.02.2025.
//

import Foundation

struct AIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
    let systemFingerprint: String?
    let serviceTier: String
    
    enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices, usage
        case systemFingerprint = "system_fingerprint"
        case serviceTier = "service_tier"
    }
}

struct Choice: Codable {
    let index: Int
    let message: Message
    let logprobs: String?
    let finishReason: String
    
    enum CodingKeys: String, CodingKey {
        case index, message, logprobs
        case finishReason = "finish_reason"
    }
}

struct Message: Codable {
    let role: String
    let content: String
    let refusal: String?
}

struct Usage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    let promptTokensDetails: TokenDetails
    let completionTokensDetails: TokenDetails
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
        case promptTokensDetails = "prompt_tokens_details"
        case completionTokensDetails = "completion_tokens_details"
    }
}

struct TokenDetails: Codable {
    let cachedTokens: Int?
    let audioTokens: Int?
    let reasoningTokens: Int?
    let acceptedPredictionTokens: Int?
    let rejectedPredictionTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case cachedTokens = "cached_tokens"
        case audioTokens = "audio_tokens"
        case reasoningTokens = "reasoning_tokens"
        case acceptedPredictionTokens = "accepted_prediction_tokens"
        case rejectedPredictionTokens = "rejected_prediction_tokens"
    }
}
