import XCTest
@testable import MoviehubSearch
import MoviehubTypes
import ComposableArchitecture
import ComposableArchitectureTestSupport
import Overture

final class MoviehubSearchTests: XCTestCase {
  let scheduler = DispatchQueue.testScheduler
  lazy var environment = SearchEnvironment(
    provider: .mock,
    mainQueue: self.scheduler.eraseToAnyScheduler()
  )

  func testSearchHappyFlow() {
    let store = TestStore(
      initialState: SearchState(
        query: "",
        items: nil,
        itemImageStates: [:],
        shouldShowSpinner: false
      ),
      reducer: searchReducer,
      environment: update(self.environment) {
        $0.provider.multiSearch = { query in Effect(value: query.isEmpty ? nil : [.movie(dummyMovie)]) }
        $0.provider.searchResultImage = { _ in Effect(value: Data()) }
      }
    )

    store.assert(
      .send(.textChanged("I")) {
        $0.query = "I"
      },
      .do { self.scheduler.advance(by: .milliseconds(250)) },
      // No search should be performed, because of debouncing
      .send(.textChanged("In")) {
        $0.query = "In"
      },
      .do { self.scheduler.advance(by: .milliseconds(300)) },
      .receive(.performSearch) {
        $0.shouldShowSpinner = true
      },
      .do { self.scheduler.advance() },
      .receive(.resultChanged([.movie(dummyMovie)])) {
        $0.items = [.movie(dummyMovie)]
        $0.shouldShowSpinner = false
      },
      .do { self.scheduler.advance() },
      .receive(.setImageState(for: .movie(dummyMovie), to: .loaded(Data()))) {
        $0.itemImageStates[dummyMovie.id] = .loaded(Data())
      },
      .send(.textChanged("")) {
        $0.query = ""
      },
      .receive(.resultChanged(nil)) {
        $0.itemImageStates = [:]
        $0.items = nil
      }
    )
  }

  func testSearchUnhappyFlow() {
    let store = TestStore(
      initialState: SearchState(
        query: "",
        items: nil,
        itemImageStates: [:],
        shouldShowSpinner: false
      ),
      reducer: searchReducer,
      environment: update(self.environment) {
        $0.provider.multiSearch = { _ in Effect(value: nil) }
        $0.provider.searchResultImage = { _ in Effect(value: nil) }
      }
    )

    store.assert(
      .send(.textChanged("I")) {
        $0.query = "I"
      },
      .do { self.scheduler.advance(by: .milliseconds(300)) },
      .receive(.performSearch) {
        $0.shouldShowSpinner = true
      },
      .do { self.scheduler.advance() },
      .receive(.resultChanged(nil)) {
        $0.items = nil
        $0.shouldShowSpinner = false
      },
      .send(.textChanged("")) {
        $0.query = ""
      },
      .receive(.resultChanged(nil)) {
        $0.itemImageStates = [:]
        $0.items = nil
        $0.shouldShowSpinner = false
      }
    )
  }

  static var allTests = [
    ("testSearchHappyFlow", testSearchHappyFlow),
    ("testSearchUnhappyFlow", testSearchUnhappyFlow)
  ]
}
