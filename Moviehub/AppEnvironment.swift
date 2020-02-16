import Foundation
import API
import Overture

public struct AppEnvironment {
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
      calendar: .mock,
      apiProvider: .mock
    )
  }
}

extension Calendar {
  public static var mock: Calendar {
    update(Calendar(identifier: .gregorian), {
      $0.firstWeekday = 1
      $0.locale = Locale(identifier: "se_SE")
      $0.timeZone = TimeZone(identifier: "Europe/Stockholm")!
    })
  }
}
