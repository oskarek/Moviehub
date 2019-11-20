import Foundation
import AppSecrets
import Combine
import MediaItem
import ComposableArchitecture

let apiKey = AppSecrets.themoviedbApiKey
let baseUrl = URL(string: "https://api.themoviedb.org/4")!

struct SearchResults: Codable {
  let results: [MediaItem]
}

public func multiSearch(query: String) -> Effect<[MediaItem]?> {
  guard !query.isEmpty else { return .sync { nil } }
  
  let path = "/search/multi"
  var components = URLComponents(string: baseUrl.absoluteString + path)!
  components.queryItems = [
    URLQueryItem(name: "query", value: query)
  ]
  
  let headers = ["Authorization": "Bearer " + apiKey]
  var request = URLRequest(url: components.url(relativeTo: baseUrl)!)
  request.allHTTPHeaderFields = headers

  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase

  return URLSession.shared.dataTaskPublisher(for: request)
    .map { data, _ in data }
    .decode(type: SearchResults.self, decoder: decoder)
    .map { $0.results }
    .replaceError(with: [])
    .eraseToEffect()
}
