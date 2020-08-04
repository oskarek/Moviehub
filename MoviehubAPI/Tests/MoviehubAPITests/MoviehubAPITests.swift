import XCTest
@testable import MoviehubAPI
import MoviehubTypes
import ComposableArchitecture

final class MoviehubAPITests: XCTestCase {
  func testEncodeAndDecode() {
    // Property: decode . encode == id
    let item = MediaItem.dummyMovieItem

    guard let data = try? tmdbEncoder.encode(item) else {
      XCTFail("Couldn't encode MediaItem")
      return
    }

    guard let decodedItem = try? tmdbDecoder.decode(MediaItem.self, from: data) else {
      XCTFail("Couldn't decode MediaItem")
      return
    }

    XCTAssertEqual(item, decodedItem)
  }

  func testDispatchRequests() {
    let dispatcher = TMDbDispatcher(useSampleData: true)
    _ = dispatcher.dispatch(request: .movie(id: 0)).sink { movie in
      XCTAssertNotNil(movie)
      XCTAssertEqual(movie?.title, "Interstellar")
    }
    _ = dispatcher.dispatch(request: .multiSearch(query: "")).sink { mediaItems in
      XCTAssertEqual(mediaItems?.count, 3)
    }
    _ = dispatcher.dispatch(request: .searchResultImage(imagePath: "")).sink { image in
      XCTAssertNotNil(image)
      XCTAssertEqual(image?.size, .init(width: 92, height: 138))
    }
  }

  static var allTests = [
    ("testEncodeAndDecode", testEncodeAndDecode)
  ]
}
