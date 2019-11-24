import Foundation
import AppSecrets
import Combine
import MediaItem
import ComposableArchitecture
import Overture

let apiKey = AppSecrets.themoviedbApiKey
let baseUrl = URL(string: "https://api.themoviedb.org/4")!
let imageBaseUrl = URL(string: "https://image.tmdb.org/t/p")!

private let tmdbDecoder = update(JSONDecoder(), mut(\.keyDecodingStrategy, .convertFromSnakeCase))

private func tmdbRequest(path: String, parameters: [String: String] = [:]) -> URLRequest {
  var components = URLComponents(string: path)!
  components.queryItems = parameters.map(URLQueryItem.init)

  let headers = ["Authorization": "Bearer " + apiKey]
  var request = URLRequest(url: components.url(relativeTo: baseUrl)!)
  request.allHTTPHeaderFields = headers

  return request
}

struct SearchResults: Codable {
  let results: [MediaItem]
}

/// Hit the multi-search api endpoint. Returns a list of MediaItems, that matches the search query.
/// - Parameter query: The string to search for.
public func multiSearch(query: String) -> Effect<[MediaItem]?> {
  guard !query.isEmpty else { return .sync { nil } }

  let path = baseUrl.absoluteString + "/search/multi"
  let request = tmdbRequest(path: path, parameters: ["query": query])

  return URLSession.shared.dataTaskPublisher(for: request)
    .map { data, _ in data }
    .decode(type: SearchResults.self, decoder: tmdbDecoder)
    .map { $0.results }
    .replaceError(with: nil)
    .eraseToEffect()
}

private func imagePath(for mediaItem: MediaItem) -> String? {
  switch mediaItem {
  case let .movie(movie):
    return movie.posterPath.map { imageBaseUrl.absoluteString + "/w92" + $0 }
  case let .tv(tvShow):
    return tvShow.posterPath.map { imageBaseUrl.absoluteString + "/w92" + $0 }
  case let .person(person):
    return person.profilePath.map { imageBaseUrl.absoluteString + "/w185" + $0 }
  }
}

/// Fetch an image for a mediaItem to display in the search results.
public func searchResultImage(for mediaItem: MediaItem) -> Effect<Data?> {
  guard let path = imagePath(for: mediaItem) else { return .sync { nil } }

  let request = tmdbRequest(path: path)
  return URLSession.shared.dataTaskPublisher(for: request)
    .map { data, _ in data }
    .replaceError(with: nil)
    .eraseToEffect()
}
