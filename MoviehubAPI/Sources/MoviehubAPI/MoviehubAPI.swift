import Foundation
import Combine
import MoviehubTypes
import ComposableArchitecture
import MoviehubUtils

func update<A>(_ aaa: A, _ fs: ((inout A) -> Void)...) -> A {
  var aaa = aaa
  fs.forEach { fff in fff(&aaa) }
  return aaa
}

// MARK: Configurations constants

let apiKey = AppSecrets.themoviedbApiKey
let baseUrl = URL(string: "https://api.themoviedb.org/3")!
let imageBaseUrl = URL(string: "https://image.tmdb.org/t/p")!

let tmdbDateFormatter = update(DateFormatter()) {
  $0.dateFormat = "yyyy-MM-dd"
}

let tmdbDecoder = update(JSONDecoder()) {
  $0.keyDecodingStrategy = .convertFromSnakeCase
  $0.dateDecodingStrategy = .formatted(tmdbDateFormatter)
}
let tmdbEncoder = update(JSONEncoder()) {
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
  public var multiSearch: (_ query: String) -> Effect<[MediaItem]?, Never>
  /// Fetch an image for a mediaItem to display in the search results.
  public var searchResultImage: (_ mediaItem: MediaItem) -> Effect<Data?, Never>
  /// Get extended information about a movie, via its id
  public var movie: (_ movieId: Movie.ID) -> Effect<ExtendedMovie?, Never>

  public init(
    multiSearch: @escaping (_ query: String) -> Effect<[MediaItem]?, Never>,
    searchResultImage: @escaping (_ mediaItem: MediaItem) -> Effect<Data?, Never>,
    movie: @escaping (_ movieId: Movie.ID) -> Effect<ExtendedMovie?, Never>) {
    self.multiSearch = multiSearch
    self.searchResultImage = searchResultImage
    self.movie = movie
  }
}

// MARK: Live implementation of TMDbProver

private func tmdbData(
  path: String,
  parameters: [String: String] = [:]
) -> AnyPublisher<Data, URLError> {
  let components = update(URLComponents(string: path)!) {
    $0.queryItems = parameters.map(URLQueryItem.init)
  }

  let headers = ["Authorization": "Bearer " + apiKey]
  let url = components.url(relativeTo: baseUrl)!
  let request: URLRequest = update(URLRequest(url: url), { $0.allHTTPHeaderFields = headers })
  return URLSession.shared.dataTaskPublisher(for: request)
    .map { data, _ in data }
    .eraseToAnyPublisher()
}

func multiSearch(query: String) -> Effect<[MediaItem]?, Never> {
  guard !query.isEmpty else { return Effect(value: nil) }

  let path = baseUrl.absoluteString + "/search/multi"
  return tmdbData(path: path, parameters: ["query": query])
    .decode(type: SearchResults.self, decoder: tmdbDecoder)
    .map { $0.results.compactMap(\.base) }
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

func searchResultImage(for mediaItem: MediaItem) -> Effect<Data?, Never> {
  guard let path = imagePath(for: mediaItem) else { return Effect(value: nil) }

  return tmdbData(path: path)
    .map(Optional.some)
    .replaceError(with: nil)
    .eraseToEffect()
}

func movie(for movieId: Movie.ID) -> Effect<ExtendedMovie?, Never> {
  let path = baseUrl.absoluteString + "/movie/\(movieId)"

  return tmdbData(path: path)
    .decode(type: ExtendedMovie?.self, decoder: tmdbDecoder)
    .replaceError(with: nil)
    .eraseToEffect()
}

extension TMDbProvider {
  public static var live: TMDbProvider {
    TMDbProvider(
      multiSearch: multiSearch(query:),
      searchResultImage: searchResultImage(for:),
      movie: movie(for:)
    )
  }

  public static var mock: TMDbProvider {
    TMDbProvider(
      multiSearch: { _ in Effect(value: nil) },
      searchResultImage: { _ in Effect(value: nil) },
      movie: { _ in Effect(value: nil) }
    )
  }
}
