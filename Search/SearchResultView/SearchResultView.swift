import SwiftUI
import MediaItem
import Overture
import Utils

struct SearchResultCell: View {
  let mediaItem: MediaItem
  var body: some View {
    HStack {
      VStack {
        Image(uiImage: UIColor.lightGray.image(.init(width: 92, height: 138)))
          .resizable()
          .aspectRatio(contentMode: .fit)
      }
      VStack(alignment: .leading) {
        Text(mediaItem.headline)
          .font(.headline)
        Text(mediaItem.subheadline)
          .font(.caption)
      }
      Spacer()
    }
    .padding(6)
    .frame(height: 100)
    .listRowInsets(.init())
  }
}

struct SearchResultCell_Previews: PreviewProvider {
  static let items = [MediaItem.movie(dummyMovie), .tv(dummyTVShow), .person(dummyPerson)]

  static var previews: some View {
    Group {
      ForEach(items) { item in
        SearchResultCell(mediaItem: item)
          .previewLayout(.sizeThatFits)
          .previewDisplayName(item.headline)
      }
    }
  }
}
