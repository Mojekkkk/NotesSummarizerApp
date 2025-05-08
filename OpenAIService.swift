import Foundation

class OpenAIService {
    static let shared = OpenAIService()

    private let apiKey = "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"
    private let endpoint = "https://api.openai.com/v1/chat/completions"

    func summarize(text: String, type: String, percent: Int, completion: @escaping (String) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion("Invalid URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt = """
        Summarize the following text as \(type). Limit the summary to approximately \(percent)% of the original length.
        Text:
        \(text)
        """

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful summarizer."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let result = try? JSONDecoder().decode(OpenAIResponse.self, from: data) {
                    completion(result.choices.first?.message.content ?? "No summary found.")
                } else {
                    completion("Failed to parse response.")
                }
            } else {
                completion("Error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        task.resume()
    }

    
}

struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
