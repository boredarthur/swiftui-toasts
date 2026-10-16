import XCTest
import SwiftUI
@testable import Toasts

@MainActor
final class ToastManagerTests: XCTestCase {
  func testAppendToast() {
    let manager = ToastManager()
    let toast = ToastValue(message: "Test Message")
    
    let model = manager.append(toast)
    
    XCTAssertEqual(manager.models.count, 1)
    XCTAssertTrue(manager.models.contains(where: { $0 === model }))
    XCTAssertEqual(model.message, "Test Message")
  }
  
  func testRemoveToast() {
    let manager = ToastManager()
    let toast = ToastValue(message: "Test Message")
    let model = manager.append(toast)
    
    manager.remove(model)
    
    XCTAssertTrue(manager.models.isEmpty)
  }
  
  func testIsPresented() {
    let manager = ToastManager()
    
    XCTAssertFalse(manager.isPresented)
    
    let toast = ToastValue(message: "Test Message")
    manager.append(toast)
    
    XCTAssertTrue(manager.isPresented)
  }
  
  func testOnAppear() {
    let manager = ToastManager()
    
    XCTAssertFalse(manager.isAppeared)
    
    manager.onAppear()
    
    XCTAssertTrue(manager.isAppeared)
  }
  
  func testStartRemovalTask() async {
    let manager = ToastManager()
    let toast = ToastValue(message: "Test Message", duration: 0.1)
    let model = manager.append(toast)
    
    await manager.startRemovalTask(for: model)
    
    XCTAssertTrue(manager.models.isEmpty)
  }
  
  func testAppendWithTask() async throws {
    let manager = ToastManager()
    
    let result = try await manager.append(
      message: "Loading...",
      task: {
        try await Task.sleep(seconds: 0.1)
        return "Success"
      },
      onSuccess: { result in
        ToastValue(icon: Image(systemName: "checkmark.circle"), message: result)
      },
      onFailure: { error in
        ToastValue(icon: Image(systemName: "xmark.circle"), message: error.localizedDescription)
      }
    )
    
    XCTAssertEqual(result, "Success")
    XCTAssertEqual(manager.models.count, 1)
    XCTAssertEqual(manager.models.first?.message, "Success")
  }

  func testAppendWithErrorTask() async throws {
    let manager = ToastManager()

    do {
      try await manager.append(
        message: "Loading...",
        task: {
          try await Task.sleep(seconds: 0.1)
          throw NSError(domain: "", code: 0)
        },
        onSuccess: { result in
          ToastValue(icon: Image(systemName: "checkmark.circle"), message: result)
        },
        onFailure: { error in
          ToastValue(icon: Image(systemName: "xmark.circle"), message: "Error")
        }
      )
    } catch {}
    XCTAssertEqual(manager.models.count, 1)
    XCTAssertEqual(manager.models.first?.message, "Error")
  }

  func testSameKeyReplacesInPlace() {
    let manager = ToastManager()
    let first = manager.append(ToastValue(message: "One", key: "k"))

    let second = manager.append(ToastValue(message: "Two", detail: "d", accessibilityMessage: "a", key: "k"))

    XCTAssertEqual(manager.models.count, 1)
    XCTAssertTrue(first === second)
    XCTAssertEqual(manager.models.first?.message, "Two")
    XCTAssertEqual(manager.models.first?.detail, "d")
    XCTAssertEqual(manager.models.first?.accessibilityMessage, "a")
  }

  func testDifferentAndNilKeysAppendSeparately() {
    let manager = ToastManager()
    manager.append(ToastValue(message: "A", key: "a"))
    manager.append(ToastValue(message: "B", key: "b"))
    manager.append(ToastValue(message: "C"))
    manager.append(ToastValue(message: "D"))

    XCTAssertEqual(manager.models.count, 4)
  }

  func testRemovedKeyIsNotReused() {
    let manager = ToastManager()
    let first = manager.append(ToastValue(message: "One", key: "k"))
    manager.remove(first)

    let second = manager.append(ToastValue(message: "Two", key: "k"))

    XCTAssertFalse(first === second)
    XCTAssertEqual(manager.models.count, 1)
  }

  func testAccessibilityTextPrefersAccessibilityMessage() {
    XCTAssertEqual(accessibilityText(for: ToastValue(message: "M", detail: "D")), "M. D")
    XCTAssertEqual(accessibilityText(for: ToastValue(message: "M")), "M")
    XCTAssertEqual(
      accessibilityText(for: ToastValue(message: "M", detail: "D", accessibilityMessage: "Spoken")),
      "Spoken"
    )
  }

  func testOnDismissFiresExactlyOnceOnRemove() {
    let manager = ToastManager()
    var count = 0
    let model = manager.append(ToastValue(message: "M", onDismiss: { count += 1 }))

    manager.remove(model)
    manager.remove(model)

    XCTAssertEqual(count, 1)
  }

  func testOnDismissNotCalledOnReplaceButFinalValueFiresOnRemove() {
    let manager = ToastManager()
    var first = 0
    var second = 0
    let model = manager.append(ToastValue(message: "One", key: "k", onDismiss: { first += 1 }))
    manager.append(ToastValue(message: "Two", key: "k", onDismiss: { second += 1 }))

    XCTAssertEqual(first, 0)
    XCTAssertEqual(second, 0)

    manager.remove(model)

    XCTAssertEqual(first, 0)
    XCTAssertEqual(second, 1)
  }

  func testReplaceWithoutOnDismissKeepsTheEarlierOne() {
    let manager = ToastManager()
    var first = 0
    let model = manager.append(ToastValue(message: "One", key: "k", onDismiss: { first += 1 }))
    manager.append(ToastValue(message: "Two", key: "k"))

    manager.remove(model)

    XCTAssertEqual(first, 1)
  }

  func testOnDismissFiresWhenTimerRemoves() async {
    let manager = ToastManager()
    var count = 0
    let model = manager.append(ToastValue(message: "M", duration: 0.05, onDismiss: { count += 1 }))

    await manager.startRemovalTask(for: model)

    XCTAssertEqual(count, 1)
  }

  func testReplaceRestartsTimerGeneration() {
    let manager = ToastManager()
    let model = manager.append(ToastValue(message: "One", key: "k"))
    let before = model.restartCount

    manager.append(ToastValue(message: "Two", key: "k"))

    XCTAssertEqual(model.restartCount, before + 1)
  }

  func testReplaceAppliesNewDuration() {
    let manager = ToastManager()
    let model = manager.append(ToastValue(message: "One", duration: 1, key: "k"))

    manager.append(ToastValue(message: "Two", duration: 5, key: "k"))

    XCTAssertEqual(model.duration, 5)
  }
}
