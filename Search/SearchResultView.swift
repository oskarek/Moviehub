import SwiftUI
import MediaItem

private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd"
  return formatter
}()

private func title(for mediaItem: MediaItem) -> String {
  switch mediaItem {
  case let .movie(movie):
    let title = movie.title ?? "Unknown title"
    let year = movie.releaseDate
      .flatMap(dateFormatter.date(from:))
      .map { "\(Calendar.current.component(.year, from: $0))" } ?? "?"
    return "\(title) (\(year))"
  case let .tv(tvShow):
    let name = tvShow.name ?? "Unknown name"
    let year = tvShow.firstAirDate
      .flatMap(dateFormatter.date(from:))
      .map { "\(Calendar.current.component(.year, from: $0))" } ?? "?"
    return "\(name) (\(year))"
  case let .person(person):
    return person.name ?? "Unknown name"
  }
}

private func subtitle(for mediaItem: MediaItem) -> String {
  switch mediaItem {
  case let .movie(movie):
    return movie.overview ?? "Unknown title"
  case let .tv(tvShow):
    return tvShow.overview ?? "Unknown name"
  case let .person(person):
    guard let knownFor = person.knownFor else {
      return "Not known for anything. A loser."
    }
    
    let knownForString = knownFor.map(title(for:)).joined(separator: ", ")
    return "Known for: \(knownForString)"
  }
}

struct SearchResultCell: View {
  let mediaItem: MediaItem
  var body: some View {
    HStack {
      VStack {
        Image("interstellar_poster").resizable().aspectRatio(contentMode: .fit)
      }
      VStack(alignment: .leading) {
        Text(title(for: mediaItem))
          .font(.headline)
        Text(subtitle(for: mediaItem))
          .font(.caption)
      }
      Spacer()
    }.frame(height: 90)//.padding(.all, 8)
  }
}

struct SearchResultCell_Previews: PreviewProvider {
  static let item = dummyMediaItem
  
  static var previews: some View {
    SearchResultCell(mediaItem: item).previewLayout(.fixed(width: 450, height: 100))
  }
}
