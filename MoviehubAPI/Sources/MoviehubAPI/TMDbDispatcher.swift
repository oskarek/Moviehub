import Foundation
import ComposableArchitecture
import MoviehubUtils

/// Type responible for dispatching TMDbRequests
struct TMDbDispatcher {
  let useSampleData: Bool

  func dispatch<DataType>(request: TMDbRequest<DataType>) -> Effect<DataType?, Never> {
    guard !useSampleData else {
      return .init(value: request.decode(request.sampleData))
    }
    return URLSession.shared.dataTaskPublisher(for: URLRequest(from: request))
      .map { request.decode($0.data) }
      .replaceError(with: nil)
      .eraseToEffect()
  }
}

extension URLRequest {
  init<DataType>(from tmdbRequest: TMDbRequest<DataType>) {
    let components = configure(URLComponents(string: tmdbRequest.baseURL.rawValue + tmdbRequest.path)!) {
      $0.queryItems = tmdbRequest.parameters.map(URLQueryItem.init)
    }
    let headers = ["Authorization": "Bearer " + AppSecrets.themoviedbApiKey]
    self = configure(URLRequest(url: components.url!)) { $0.allHTTPHeaderFields = headers }
  }
}
