import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.unsplash.com"
    private let accessKey = "lkp-NxLYUUkJgPmticKspw-Y4owOQ86vYRO8vR0D_j0"

    func fetchPhotos(page: Int, completion: @escaping (Result<[MediaItem], Error>) -> Void) {
        let perPage = 20
        guard let url = URL(string: "\(baseURL)/photos?page=\(page)&per_page=\(perPage)&client_id=\(accessKey)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Ошибка: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("Нет данных")
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }

            do {
                let result = try JSONDecoder().decode([MediaItem].self, from: data)
                completion(.success(result))
            } catch {
                print("Ошибка декодирования: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }

    func searchMedia(query: String, page: Int, completion: @escaping (Result<[MediaItem], Error>) -> Void) {
        let perPage = 20
        guard let url = URL(string: "\(baseURL)/search/photos?page=\(page)&per_page=\(perPage)&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&client_id=\(accessKey)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Ошибка: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("Нет данных")
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }

            do {
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                completion(.success(searchResult.results))
            } catch {
                print("Ошибка декодирования: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

struct SearchResult: Codable {
    let results: [MediaItem]
}

