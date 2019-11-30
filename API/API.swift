import Foundation
import AppSecrets
import Combine
import Types
import ComposableArchitecture
import Overture
import Utils

public let tmdbDateFormatter = update(DateFormatter(), concat(
  mut(\.dateFormat, "yyyy-MM-dd")
))

public let tmdbDecoder = update(JSONDecoder(), concat(
  mut(\.keyDecodingStrategy, .convertFromSnakeCase),
  mut(\.dateDecodingStrategy, .formatted(tmdbDateFormatter))
))
public let tmdbEncoder = update(JSONEncoder(), concat(
  mut(\.keyEncodingStrategy, .convertToSnakeCase),
  mut(\.dateEncodingStrategy, .formatted(tmdbDateFormatter))
))

struct SearchResults: Decodable {
  let results: [FailableDecodable<MediaItem>]
}

public protocol TMDbProvider {
  func multiSearch(query: String) -> Effect<[MediaItem]?>
  func searchResultImage(for mediaItem: MediaItem) -> Effect<Data?>
}

public struct LiveTMDbProvider: TMDbProvider {
  let apiKey = AppSecrets.themoviedbApiKey
  let baseUrl = URL(string: "https://api.themoviedb.org/4")!
  let imageBaseUrl = URL(string: "https://image.tmdb.org/t/p")!

  private func tmdbRequest(path: String, parameters: [String: String] = [:]) -> URLRequest {
    let components = update(
      URLComponents(string: path)!,
      mut(\.queryItems, parameters.map(URLQueryItem.init))
    )

    let headers = ["Authorization": "Bearer " + apiKey]
    let url = components.url(relativeTo: baseUrl)!
    return update(URLRequest(url: url), mut(\.allHTTPHeaderFields, headers))
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
      .map { $0.results.compactMap(get(\.base)) }
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

  public init() {}
}
