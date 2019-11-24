import Foundation

public let dummyPerson = Person(
  profilePath: nil,
  id: 0,
  knownFor: [.movie(dummyMovie), .tv(dummyTVShow)],
  name: "Oskar Ek"
)

public struct Person: Codable, Identifiable {
  public let profilePath: String?
  public let id: Int?
  public let knownFor: [MediaItem]?
  public let name: String?
}
