import XCTest
@testable import MoviehubSearch
import MoviehubTypes
import ComposableArchitecture
import ComposableArchitectureTesting
import Overture

final class MoviehubSearchTests: XCTestCase {
    func testSearchHappyFlow() {
      assert(
        initialValue: SearchState(
          query: "",
          items: nil,
          itemImageStates: [:],
          shouldShowSpinner: false
        ),
        environment: update(SearchEnvironment.mock) {
          $0.multiSearch = { query in .pure(query.isEmpty ? nil : [.movie(dummyMovie)]) }
          $0.searchResultImage = { _ in .pure(Data()) }
        },
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
      assert(
        initialValue: SearchState(
          query: "",
          items: nil,
          itemImageStates: [:],
          shouldShowSpinner: false
        ),
        environment: update(SearchEnvironment.mock) {
          $0.multiSearch = { _ in .pure(nil) }
          $0.searchResultImage = { _ in .pure(nil) }
        },
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

    static var allTests = [
        ("testSearchHappyFlow", testSearchHappyFlow),
        ("testSearchUnhappyFlow", testSearchUnhappyFlow)
    ]
}
