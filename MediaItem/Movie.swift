import Foundation

public let dummyMovie = Movie(
  posterPath: nil,
  overview: "A nice movie about a car",
  releaseDate: "2019-06-09",
  id: 1,
  title: "Car movie",
  voteAverage: 9.0
)

public struct Movie: Codable, Identifiable {
  public let posterPath: String?
  public let overview: String?
  public let releaseDate: String?
  public let id: Int?
  public let title: String?
  public let voteAverage: Double?
}
