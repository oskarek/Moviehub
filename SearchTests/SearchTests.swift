import XCTest
@testable import Search
import ComposableArchitecture
import Types
import ComposableArchitectureTesting
import Environment
import API
import Overture

struct DummyProvider: TMDbProvider {
  let shouldFail: Bool

  func multiSearch(query: String) -> Effect<[MediaItem]?> {
    self.shouldFail
      ? .sync { nil }
      : .sync { query.isEmpty ? nil : [.movie(dummyMovie)] }
  }

  func searchResultImage(for mediaItem: MediaItem) -> Effect<Data?> {
    .sync { self.shouldFail ? nil : Data() }
  }
}

class SearchTests: ComposableArchitectureTestCase {
  func testSearchHappyFlow() {
    Current.apiProvider = DummyProvider(shouldFail: false)

    assert(
      initialValue: SearchState(
        query: "",
        items: nil,
        itemImageStates: [:],
        shouldShowSpinner: false
      ),
      reducer: searchReducer,
      steps:
      .send(.textChanged("I")) {
        $0.query = "I"
        $0.shouldShowSpinner = true
      },
      .receive(.resultChanged([.movie(dummyMovie)])) {
        $0.items = [.movie(dummyMovie)]
        $0.shouldShowSpinner = false
      },
      .receive(.setImageState(for: .movie(dummyMovie), to: .loaded(Data()))) {
        $0.itemImageStates[dummyMovie.id] = .loaded(Data())
      },
      .send(.textChanged("")) { $0.query = "" },
      .receive(.resultChanged(nil)) {
        $0.itemImageStates = [:]
        $0.items = nil
      }
    )
  }

  func testSearchUnhappyFlow() {
    Current.apiProvider = DummyProvider(shouldFail: true)

    assert(
      initialValue: SearchState(
        query: "",
        items: nil,
        itemImageStates: [:],
        shouldShowSpinner: false
      ),
      reducer: searchReducer,
      steps:
      .send(.textChanged("I")) {
        $0.query = "I"
        $0.shouldShowSpinner = true
      },
      .receive(.resultChanged(nil)) {
        $0.items = nil
        $0.shouldShowSpinner = false
      },
      .send(.textChanged("")) {
        $0.query = ""
        $0.shouldShowSpinner = true
      },
      .receive(.resultChanged(nil)) {
        $0.itemImageStates = [:]
        $0.items = nil
        $0.shouldShowSpinner = false
      }
    )
  }
}
