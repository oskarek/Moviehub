import Foundation
import MoviehubAPI
import ComposableArchitecture

public struct AppEnvironment {
  /// The main queue to be used
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  /// The current calendar
  public var calendar: Calendar
  /// The current TMDb api provider
  public var apiProvider: TMDbProvider
}

// MARK: Convenience properties

extension AppEnvironment {
  /// The current timeZone
  public var timeZone: TimeZone { self.calendar.timeZone }
  /// The current locale
  public var locale: Locale? { self.calendar.locale }
}

// MARK: Live

extension AppEnvironment {
  /// A live version of the environment
  public static var live: AppEnvironment {
    AppEnvironment(
      mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
      calendar: .autoupdatingCurrent,
      apiProvider: .live
    )
  }
}

// MARK: Mocks

extension AppEnvironment {
  /// A mock version of the environment, free from side-effects
  public static var mock: AppEnvironment {
    AppEnvironment(
      mainQueue: DispatchQueue.testScheduler.eraseToAnyScheduler(),
      calendar: .mock,
      apiProvider: .mock
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
