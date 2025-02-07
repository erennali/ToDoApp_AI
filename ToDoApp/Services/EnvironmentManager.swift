import Foundation

enum EnvironmentManager {
    enum Keys {
        static let openAIApiKey = "OPENAI_API_KEY"
    }
    
    static func getValue(_ key: String) -> String? {
        guard let value = ProcessInfo.processInfo.environment[key] else {
            #if DEBUG
            print("⚠️ Environment variable not found for key: \(key)")
            #endif
            return nil
        }
        return value
    }
    
    static var openAIApiKey: String {
        guard let apiKey = getValue(Keys.openAIApiKey) else {
            fatalError("OpenAI API key not found in environment variables. Please set OPENAI_API_KEY.")
        }
        return apiKey
    }
} 