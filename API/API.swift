import Foundation
import AppSecrets
import Combine
import Types
import ComposableArchitecture
import Overture
import Utils

// MARK: Configurations constants

let apiKey = AppSecrets.themoviedbApiKey
let baseUrl = URL(string: "https://api.themoviedb.org/4")!
let imageBaseUrl = URL(string: "https://image.tmdb.org/t/p")!

public let tmdbDateFormatter = update(DateFormatter()) {
  $0.dateFormat = "yyyy-MM-dd"
}

public let tmdbDecoder = update(JSONDecoder()) {
  $0.keyDecodingStrategy = .convertFromSnakeCase
  $0.dateDecodingStrategy = .formatted(tmdbDateFormatter)
}
public let tmdbEncoder = update(JSONEncoder()) {
  $0.keyEncodingStrategy = .convertToSnakeCase
  $0.dateEncodingStrategy = .formatted(tmdbDateFormatter)
}

struct SearchResults: Decodable {
  let results: [FailableDecodable<MediaItem>]
}

// MARK: TMDbProvider

public struct TMDbProvider {
  /// Hit the multi-search api endpoint. Returns a list of MediaItems, that matches the search query.
  /// - Parameter query: The string to search for.
  public var multiSearch: (_ query: String) -> Effect<[MediaItem]?>
  /// Fetch an image for a mediaItem to display in the search results.
  public var searchResultImage: (_ mediaItem: MediaItem) -> Effect<Data?>

  public init(
    multiSearch: @escaping (_ query: String) -> Effect<[MediaItem]?>,
    searchResultImage: @escaping (_ mediaItem: MediaItem) -> Effect<Data?>) {
    self.multiSearch = multiSearch
    self.searchResultImage = searchResultImage
  }
}

// MARK: Live implementation of TMDbProver

private func tmdbRequest(path: String, parameters: [String: String] = [:]) -> URLRequest {
  let components = update(URLComponents(string: path)!) {
    $0.queryItems = parameters.map(URLQueryItem.init)
  }

  let headers = ["Authorization": "Bearer " + apiKey]
  let url = components.url(relativeTo: baseUrl)!
  return update(URLRequest(url: url), mut(\.allHTTPHeaderFields, headers))
}

func multiSearch(query: String) -> Effect<[MediaItem]?> {
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

func searchResultImage(for mediaItem: MediaItem) -> Effect<Data?> {
  guard let path = imagePath(for: mediaItem) else { return .sync { nil } }

  let request = tmdbRequest(path: path)
  return URLSession.shared.dataTaskPublisher(for: request)
    .map { data, _ in data }
    .replaceError(with: nil)
    .eraseToEffect()
}

public let liveTMDbProvider = TMDbProvider(
  multiSearch: multiSearch,
  searchResultImage: searchResultImage
)
