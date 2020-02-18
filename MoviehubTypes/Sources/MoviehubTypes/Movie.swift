import Foundation

public let dummyMovie = Movie(
  posterPath: nil,
  overview: "A nice movie about a car",
  releaseDate: SimpleDate(year: 1993, month: 3, day: 11),
  id: 0,
  title: "Car movie",
  voteAverage: 9.0
)

public struct Movie: Codable, Identifiable, Equatable {
  public let posterPath: String?
  public let overview: String?
  public let releaseDate: SimpleDate
  public let id: Int
  public let title: String
  public let voteAverage: Double?

  public init(
    posterPath: String?,
    overview: String?,
    releaseDate: SimpleDate,
    id: Int,
    title: String,
    voteAverage: Double?
  ) {
    self.posterPath = posterPath
    self.overview = overview
    self.releaseDate = releaseDate
    self.id = id
    self.title = title
    self.voteAverage = voteAverage
  }
}
