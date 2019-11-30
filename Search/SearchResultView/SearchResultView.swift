import SwiftUI
import Types
import Overture
import Utils

struct SearchResultCell: View {
  let imageState: ImageState
  let mediaItem: MediaItem
  var body: some View {
    HStack {
      imageView(for: self.mediaItem, inState: self.imageState, ofSize: .init(width: 59, height: 88))
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
  static let imageData = UIColor.lightGray.image(.init(width: 92, height: 138)).pngData()!

  static var previews: some View {
    Group {
      ForEach(items) { item in
        SearchResultCell(imageState: .empty, mediaItem: item)
          .previewLayout(.sizeThatFits)
          .previewDisplayName(item.headline)
      }
    }
  }
}
