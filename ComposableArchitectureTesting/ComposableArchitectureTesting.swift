import ComposableArchitecture
import XCTest
import Combine

enum StepType {
  case send
  case receive
}

public struct Step<Value, Action> {
  let type: StepType
  let action: Action
  let update: (inout Value) -> Void
  let file: StaticString
  let line: UInt

  init(
    _ type: StepType,
    _ action: Action,
    file: StaticString = #file,
    line: UInt = #line,
    _ update: @escaping (inout Value) -> Void
  ) {
    self.type = type
    self.action = action
    self.update = update
    self.file = file
    self.line = line
  }
}

public extension Step {
  static func send(
    _ action: Action,
    file: StaticString = #file,
    line: UInt = #line,
    _ update: @escaping (inout Value) -> Void
  ) -> Step<Value, Action> {
    .init(.send, action, file: file, line: line, update)
  }

  static func receive(
    _ action: Action,
    file: StaticString = #file,
    line: UInt = #line,
    _ update: @escaping (inout Value) -> Void
  ) -> Step<Value, Action> {
    .init(.receive, action, file: file, line: line, update)
  }
}

func runEffect<Value, Action>(_ effect: Effect<Action>, at step: Step<Value, Action>) -> [Action] {
  var actions: [Action] = []
  let receivedCompletion = XCTestExpectation(description: "receivedCompletion")
  let cancellable = effect.sink(
    receiveCompletion: { _ in
      receivedCompletion.fulfill()
  },
    receiveValue: { actions.append($0) }
  )
  if XCTWaiter.wait(for: [receivedCompletion], timeout: 0.01) != .completed {
    cancellable.cancel()
    XCTFail("Timed out waiting for the effect to complete", file: step.file, line: step.line)
  }
  return actions
}

public func assert<Value: Equatable, Action: Equatable, Environment>(
  initialValue: Value,
  environment: Environment,
  reducer: Reducer<Value, Action, Environment>,
  steps: Step<Value, Action>...,
  file: StaticString = #file,
  line: UInt = #line
) {
  var state = initialValue
  var pendingActions: [Action] = []

  steps.grouped(by: { $0.type }).forEach { steps in
    switch steps[0].type {
    case .send:
      if !pendingActions.isEmpty {
        XCTFail(
          "Action sent before handling \(pendingActions.count) pending action(s)",
          file: steps[0].file,
          line: steps[0].line
        )
      }
      for step in steps {
        var expected = state
        let effect = reducer.run(&state, step.action, environment)
        pendingActions.append(contentsOf: runEffect(effect, at: step))
        step.update(&expected)
        XCTAssertEqual(state, expected, file: step.file, line: step.line)
      }

    case .receive:
      for step in steps {
        guard !pendingActions.isEmpty else {
          XCTFail("No pending actions to receive", file: step.file, line: step.line)
          break
        }

        let action = pendingActions.removeFirst()
        var expected = state

        XCTAssertEqual(action, step.action, file: step.file, line: step.line)
        let effect = reducer.run(&state, action, environment)
        let actions = runEffect(effect, at: step)
        pendingActions.append(contentsOf: actions)
        step.update(&expected)
        XCTAssertEqual(state, expected, file: step.file, line: step.line)
      }

      if !pendingActions.isEmpty {
        XCTFail("Assertion failed to handle \(pendingActions.count) pending actions(s)", file: file, line: line)
      }
    }
  }
  if !pendingActions.isEmpty {
    XCTFail("Assertion failed to handle \(pendingActions.count) pending actions(s)", file: file, line: line)
  }
}

// TODO: Remove this from here, only temporarily placed here
extension Array {
  func grouped<A: Equatable>(by prop: (Element) -> A) -> [[Element]] {
    guard !self.isEmpty else { return [] }
    var currGroup: [Element] = [self.first!]
    var res: [[Element]] = []
    for elem in self.dropFirst() {
      if prop(currGroup.last!) == prop(elem) {
        currGroup.append(elem)
      } else {
        res.append(currGroup)
        currGroup = [elem]
      }
    }
    if !currGroup.isEmpty {
      res.append(currGroup)
    }
    return res
  }
}
