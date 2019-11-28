//
//  Environment.swift
//  Environment
//
//  Created by Oskar Ek on 2019-11-27.
//  Copyright © 2019 Oskar Ek. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Overture

public var Current = Environment()

public struct Environment {
  /// The current calendar
  public var calendar: Calendar = .autoupdatingCurrent
}

// MARK: Convenience properties

extension Environment {
  /// The current timeZone
  public var timeZone: TimeZone { self.calendar.timeZone }
  /// The current locale
  public var locale: Locale? { self.calendar.locale }
}

// MARK: Mocks

extension Environment {
  /// A mock version of the environment, free from side-effects
  public var mock: Environment {
    Environment(
      calendar: .mock
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
