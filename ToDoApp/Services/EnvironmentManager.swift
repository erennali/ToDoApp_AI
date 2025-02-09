import Foundation

enum EnvironmentManager {
    enum Keys {
        static let apiKey = "API_KEY"
    }
    
    static func getValue(_ key: String) -> String? {
        // First try reading from .env file
        if let envPath = Bundle.main.path(forResource: ".env", ofType: nil) {
            print("DEBUG: Found .env file at path: \(envPath)")
            if let envContents = try? String(contentsOfFile: envPath, encoding: .utf8) {
                print("DEBUG: Successfully read .env file contents")
                let lines = envContents.components(separatedBy: .newlines)
                for line in lines {
                    let parts = line.components(separatedBy: "=")
                    if parts.count == 2 && parts[0].trimmingCharacters(in: .whitespaces) == key {
                        print("DEBUG: Found key '\(key)' in .env file")
                        return parts[1].trimmingCharacters(in: .whitespaces)
                    }
                }
                print("DEBUG: Key '\(key)' not found in .env file")
            } else {
                print("DEBUG: Failed to read .env file contents")
            }
        } else {
            print("DEBUG: .env file not found in bundle")
            // Print bundle path for debugging
            print("DEBUG: Bundle path: \(Bundle.main.bundlePath)")
            if let resourcePath = Bundle.main.resourcePath {
                print("DEBUG: Resource path: \(resourcePath)")
            }
        }
        
        // Then try environment variables
        if let value = ProcessInfo.processInfo.environment[key] {
            print("DEBUG: Found key '\(key)' in environment variables")
            return value
        }
        print("DEBUG: Key '\(key)' not found in environment variables")
        
        // Finally try Info.plist
        if let value = Bundle.main.object(forInfoDictionaryKey: key) as? String {
            print("DEBUG: Found key '\(key)' in Info.plist")
            return value
        }
        print("DEBUG: Key '\(key)' not found in Info.plist")
        
        print("⚠️ Value not found for key: \(key)")
        return nil
    }
    
    static var apiKey: String? {
        return getValue(Keys.apiKey)
    }
}