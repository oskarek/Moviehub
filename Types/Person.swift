import Foundation

public let dummyPerson = Person(
  profilePath: nil,
  id: 2,
  knownFor: [.movie(dummyMovie), .tv(dummyTVShow)],
  name: "Oskar Ek"
)

public struct Person: Codable, Identifiable, Equatable {
  public let profilePath: String?
  public let id: Int
  public let knownFor: [MediaItem]?
  public let name: String

  public init(
    profilePath: String?,
    id: Int,
    knownFor: [MediaItem]?,
    name: String
  ) {
    self.profilePath = profilePath
    self.id = id
    self.knownFor = knownFor
    self.name = name
  }
}
