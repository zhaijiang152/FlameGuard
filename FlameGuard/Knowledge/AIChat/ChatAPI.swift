//
//  ChatAPI.swift
//  AI
//
//  Created by 清云 on 2025/5/18.
//

import Foundation

struct GLM4Message: Codable {
    let role: String
    let content: String
}

struct GLM4Request: Codable {
    let model: String
    let messages: [GLM4Message]
    let temperature: Double?
    let top_p: Double?
    let stream: Bool?
    let stop: [String]?
    
    init(messages: [GLM4Message], temperature: Double? = 0.7) {
        self.model = "glm-4"
        self.messages = messages
        self.temperature = temperature
        self.top_p = 0.7
        self.stream = false
        self.stop = nil
    }
}

struct GLM4Response: Codable {
    let id: String?
    let created: Int?
    let model: String?
    let choices: [Choice]?
    let usage: Usage?
    
    struct Choice: Codable {
        let index: Int?
        let message: Message?
        let finish_reason: String?
        
        struct Message: Codable {
            let role: String?
            let content: String?
        }
    }
    
    struct Usage: Codable {
        let prompt_tokens: Int?
        let completion_tokens: Int?
        let total_tokens: Int?
    }
    
    func getContent() -> String? {
        return choices?.first?.message?.content
    }
}

enum GLM4APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case apiError(String)
    case noContent
}

class GLM4API {
    private let apiKey: String
    private let session: URLSession
    
    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }
    
    func sendMessage(messages: [GLM4Message],
                    completion: @escaping (Result<String, GLM4APIError>) -> Void) {
        let endpoint = "https://open.bigmodel.cn/api/paas/v4/chat/completions"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = GLM4Request(messages: messages)
        
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(requestBody)
            
            // 打印请求体用于调试
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print("Request body: \(jsonString)")
            }
        } catch {
            completion(.failure(.decodingFailed(error)))
            return
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            // 打印原始响应数据用于调试
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw response: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(GLM4Response.self, from: data)
                
                if let content = response.getContent() {
                    completion(.success(content))
                } else {
                    completion(.failure(.noContent))
                }
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }
        
        task.resume()
    }
}
