import Foundation
import ComposableArchitecture
import MoviehubUtils
import MoviehubTypes
import UIKit

// MARK: Type declaration

struct TMDbRequest<DataType> {
  enum BaseURL: String {
    case main = "https://api.themoviedb.org/3"
    case image = "https://image.tmdb.org/t/p"
  }

  let baseURL: BaseURL
  let path: String
  let parameters: [String: String]
  let decode: (Data) -> DataType?
  let sampleData: Data
}

// MARK: Decoding stuff

let tmdbDecoder = configure(JSONDecoder()) {
  $0.keyDecodingStrategy = .convertFromSnakeCase
}
let tmdbEncoder = configure(JSONEncoder()) {
  $0.keyEncodingStrategy = .convertToSnakeCase
}

struct SearchResults: Decodable {
  let results: [FailableDecodable<MediaItem>]
}

// MARK: Concrete requests

// swiftlint:disable force_try
extension TMDbRequest {
  static func multiSearch(query: String) -> TMDbRequest<[MediaItem]> {
    .init(
      baseURL: .main,
      path: "/search/multi",
      parameters: ["query": query],
      decode: { try? tmdbDecoder.decode(SearchResults.self, from: $0).results.compactMap(\.base) },
      sampleData:
        try! Data(contentsOf: Bundle.module.url(forResource: "sample_multisearch_response", withExtension: "txt")!)
    )
  }

  static func searchResultImage(imagePath: String) -> TMDbRequest<UIImage> {
    .init(
      baseURL: .image,
      path: imagePath,
      parameters: [:],
      decode: UIImage.init(data:),
      sampleData: try! Data(contentsOf: Bundle.module.url(forResource: "interstellar_poster", withExtension: "jpg")!)
    )
  }

  static func movie(id: Movie.ID) -> TMDbRequest<Movie> {
    .init(
      baseURL: .main,
      path: "/movie/\(id)",
      parameters: [:],
      decode: { try? tmdbDecoder.decode(Movie.self, from: $0) },
      sampleData: try! Data(contentsOf: Bundle.module.url(forResource: "sample_movie_response", withExtension: "txt")!)
    )
  }
}
// swiftlint:enable force_try
