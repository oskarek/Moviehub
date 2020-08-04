//
//  MoviehubApp.swift
//  Moviehub
//
//  Created by Oskar Ek on 2020-06-25.
//

import SwiftUI
import ComposableArchitecture

@main
struct MoviehubApp: App {
  let appStore = Store<AppState, AppAction>(
    initialState: AppState(),
    reducer: appReducer,
    environment: .live
  )

  var body: some Scene {
    WindowGroup {
      ContentView(store: appStore)
    }
  }
}
