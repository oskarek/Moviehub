import XCTest
import ComposableArchitecture
import MoviehubTypes
@testable import Moviehub

class SearchTests: XCTestCase {
  let scheduler = DispatchQueue.testScheduler

  func testSearchHappyFlow() {
    func mockMultiSearch(delayedBy delay: DispatchQueue.SchedulerTimeType.Stride = .zero)
      -> (String) -> Effect<[MediaItem]?, Never> {
      return { query in
        Effect(value: query.isEmpty ? nil : [.dummyMovieItem])
          .delay(for: delay, scheduler: self.scheduler)
          .eraseToEffect()
      }
    }

    let store = TestStore(
      initialState: SearchState(),
      reducer: searchReducer,
      environment: SearchEnvironment(
        provider: .init(
          multiSearch: mockMultiSearch(),
          searchResultImage: { _ in Effect(value: UIImage()) },
          movie: { _ in fatalError() }
        ),
        mainQueue: self.scheduler.eraseToAnyScheduler()
      )
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
      .do { self.scheduler.advance(by: .milliseconds(299)) },
      // Advanced 1 millisecond less than debounce time. Nothing chould happen.
      .do { self.scheduler.advance(by: .milliseconds(1)) },
      // Finally, debounce time is reached and action should be received
      .receive(.performSearch),
      .do { self.scheduler.advance() },
      .receive(.resultChanged([.dummyMovieItem])) {
        $0.items = [.dummyMovieItem]
      },
      .do { self.scheduler.advance() },
      .receive(.setImageState(for: MediaItem.dummyMovieItem.id, to: .loaded(UIImage()))) {
        $0.itemImageStates[MediaItem.dummyMovieItem.id] = .loaded(UIImage())
      },
      .environment { $0.provider.multiSearch = mockMultiSearch(delayedBy: .milliseconds(350)) },
      .send(.textChanged("Int")) {
        $0.query = "Int"
      },
      .do { self.scheduler.advance(by: .milliseconds(300)) },
      .receive(.performSearch),
      .do { self.scheduler.advance(by: .milliseconds(299)) },
      .do { self.scheduler.advance(by: .milliseconds(1)) },
      // After exactly 300 milliseconds, the activity indicator should show
      .receive(.showActivityIndicator) {
        $0.shouldShowActivityIndicator = true
      },
      .do { self.scheduler.advance(by: .milliseconds(49)) },
      .do { self.scheduler.advance(by: .milliseconds(1)) },
      // after 50 additional milliseconds, result should be updated
      .receive(.resultChanged([.dummyMovieItem])) {
        $0.shouldShowActivityIndicator = false
      },
      .do { self.scheduler.advance() },
      .receive(.setImageState(for: MediaItem.dummyMovieItem.id, to: .loaded(UIImage()))),
      .send(.textChanged("")) {
        $0.query = ""
      },
      .receive(.resultChanged(nil)) {
        $0.itemImageStates = [:]
        $0.items = []
      }
    )
  }

  func testSearchUnhappyFlow() {
    let store = TestStore(
      initialState: SearchState(),
      reducer: searchReducer,
      environment: SearchEnvironment(
        provider: .init(
          multiSearch: { _ in Effect(value: nil) },
          searchResultImage: { _ in Effect(value: nil) },
          movie: { _ in fatalError() }
        ),
        mainQueue: self.scheduler.eraseToAnyScheduler()
      )
    )

    store.assert(
      .send(.textChanged("I")) {
        $0.query = "I"
      },
      .do { self.scheduler.advance(by: .milliseconds(300)) },
      .receive(.performSearch),
      .do { self.scheduler.advance() },
      .receive(.resultChanged(nil)),
      .send(.textChanged("")) {
        $0.query = ""
      },
      .receive(.resultChanged(nil))
    )
  }
}
