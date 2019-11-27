import XCTest
@testable import MediaItem
import API

class MediaItemTests: XCTestCase {
  func testEncodeAndDecode() {
    // Property: decode . encode == id
    let item = dummyMediaItem

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
}
