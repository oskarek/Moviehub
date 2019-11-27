import Foundation
import Utils

public let dummyMovie = Movie(
  posterPath: nil,
  overview: "A nice movie about a car",
  releaseDate: Date(timeIntervalSince1970: 300000000),
  id: 0,
  title: "Car movie",
  voteAverage: 9.0
)

public struct Movie: Codable, Identifiable, Equatable {
  public let posterPath: String?
  public let overview: String?
  public let releaseDate: Date
  public let id: Int
  public let title: String
  public let voteAverage: Double?

  public init(
    posterPath: String?,
    overview: String?,
    releaseDate: Date,
    id: Int,
    title: String,
    voteAverage: Double?
  ) {
    self.posterPath = posterPath
    self.overview = overview
    self.releaseDate = releaseDate.zeroSeconds
    self.id = id
    self.title = title
    self.voteAverage = voteAverage
  }
}
