import XCTest
import SwiftUI
@testable import Toasts

@MainActor
final class ToastStyleTests: XCTestCase {
  func testNoStyleMeansNoOverrides() {
    XCTAssertEqual(ToastStyle(), ToastStyle(messageFont: nil, background: nil, cornerRadius: nil, shadow: nil, height: nil))
    XCTAssertEqual(EnvironmentValues().toastStyle, ToastStyle())
    XCTAssertEqual(ToastManager().style, ToastStyle())
    let style = ToastStyle()
    XCTAssertNil(style.edgeSpacing)
    XCTAssertNil(style.messageTracking)
    XCTAssertNil(style.buttonTracking)
    XCTAssertNil(style.leadingPadding)
    XCTAssertNil(style.buttonHeight)
    XCTAssertNil(style.buttonHorizontalPadding)
    XCTAssertNil(style.buttonMinWidth)
    XCTAssertNil(style.buttonLeadingPadding)
    XCTAssertNil(style.buttonTrailingPadding)
  }

  func testDetailIsOptionalAndKept() {
    XCTAssertNil(ToastValue(message: "Plain").detail)

    let toast = ToastValue(message: "Card hidden", detail: "Sign in any time", duration: 5)
    XCTAssertEqual(toast.message, "Card hidden")
    XCTAssertEqual(toast.detail, "Sign in any time")
    XCTAssertEqual(toast.duration, 5)
  }

  func testTheStyleIsPartOfTheEnvironment() {
    var environment = EnvironmentValues()
    let style = ToastStyle(messageColor: .red, cornerRadius: 14, height: 56, edgeSpacing: 6)
    environment.toastStyle = style

    XCTAssertEqual(environment.toastStyle, style)
    XCTAssertNotEqual(ToastStyle(buttonHeight: 34), ToastStyle())
    XCTAssertNotEqual(ToastStyle(messageTracking: -0.32), ToastStyle())
    XCTAssertNotEqual(environment.toastStyle, ToastStyle())
  }

  func testAToastWithADetailStillAppendsAndRemoves() {
    let manager = ToastManager()
    let model = manager.append(ToastValue(message: "Hidden", detail: "Stays in Settings"))

    XCTAssertEqual(model.detail, "Stays in Settings")
    manager.remove(model)
    XCTAssertTrue(manager.models.isEmpty)
  }
}
