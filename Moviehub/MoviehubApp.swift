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
  var body: some Scene {
    WindowGroup {
      ContentView(store: store)
    }
  }
}
