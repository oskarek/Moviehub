import Foundation
import Overture
import Types
import API
import Environment

extension MediaItem {
  var headline: String {
    switch self {
    case let .movie(movie):
      let title = movie.title
      let year = "\(Current.calendar.component(.year, from: movie.releaseDate))"
      return "\(title) (\(year))"
    case let .tv(tvShow):
      let name = tvShow.name
      let year = "\(Current.calendar.component(.year, from: tvShow.firstAirDate))"
      return "\(name) (\(year))"
    case let .person(person):
      return person.name
    }
  }

  var subheadline: String {
    switch self {
    case let .movie(movie):
      return movie.overview ?? ""
    case let .tv(tvShow):
      return tvShow.overview ?? ""
    case let .person(person):
      guard let knownFor = person.knownFor else {
        return "Not known for anything. A loser."
      }

      let knownForString = knownFor.map(get(\.headline)).joined(separator: ", ")
      return "Known for: \(knownForString)"
    }
  }
}
