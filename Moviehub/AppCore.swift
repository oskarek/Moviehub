import Foundation
import ComposableArchitecture
import MoviehubAPI
import MoviehubTypes
import UIKit

// MARK: State

struct AppState {
  var searchText: String = ""
  var searchResult: [MediaItem] = []
  var searchItemImageStates: [MediaItem.ID: LoadingState<UIImage>] = [:]
  var searchShouldShowActivityIndicator: Bool = false
}

extension AppState {
  var search: SearchState {
    get {
      SearchState(
        query: self.searchText,
        items: self.searchResult,
        itemImageStates: self.searchItemImageStates,
        shouldShowActivityIndicator: self.searchShouldShowActivityIndicator
      )
    }
    set {
      self.searchText = newValue.query
      self.searchResult = newValue.items
      self.searchItemImageStates = newValue.itemImageStates
      self.searchShouldShowActivityIndicator = newValue.shouldShowActivityIndicator
    }
  }
}

// MARK: Action

enum AppAction {
  case search(SearchAction)
}

// MARK: Environment

public struct AppEnvironment {
  /// The current TMDb api provider
  public var apiProvider: TMDbProvider
  /// The current calendar
  public var calendar: Calendar
  /// The main queue to be used
  public var mainQueue: AnySchedulerOf<DispatchQueue>
}

extension AppEnvironment {
  /// The current timeZone
  public var timeZone: TimeZone { self.calendar.timeZone }
  /// The current locale
  public var locale: Locale? { self.calendar.locale }
}

extension AppEnvironment {
  /// A live version of the environment
  public static var live: AppEnvironment {
    AppEnvironment(
      apiProvider: .live,
      calendar: .autoupdatingCurrent,
      mainQueue: DispatchQueue.main.eraseToAnyScheduler()
    )
  }

  /// A mock version of the environment, free from side-effects
  public static func mock(
    apiProvider: TMDbProvider = .mock(),
    calendar: Calendar = .mock,
    mainQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
  ) -> AppEnvironment {
    AppEnvironment(
      apiProvider: apiProvider,
      calendar: calendar,
      mainQueue: mainQueue
    )
  }
}

extension Calendar {
  public static var mock: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.firstWeekday = 1
    calendar.locale = Locale(identifier: "se_SE")
    calendar.timeZone = TimeZone(identifier: "Europe/Stockholm")!
    return calendar
  }
}

extension AppEnvironment {
  var search: SearchEnvironment { .init(provider: self.apiProvider, mainQueue: self.mainQueue) }
}

// MARK: Reducer

let appReducer: Reducer<AppState, AppAction, AppEnvironment> =
  searchReducer.pullback(state: \.search, action: /AppAction.search, environment: \.search)
