import Foundation
import SwiftUI

/// Represents a toast notification with customizable content and behavior.
public struct ToastValue {
  internal var icon: AnyView?
  internal var message: String
  /// An optional second line, under the message.
  internal var detail: String?
  internal var button: ToastButton?
  /// If nil, the toast will persist and not disappear. Used when displaying a loading toast.
  internal var duration: TimeInterval?
  /// Spoken by VoiceOver instead of the message and detail.
  internal var accessibilityMessage: String?
  /// Presenting a toast with the key of a visible one updates that toast instead of adding another.
  internal var key: AnyHashable?
  /// Called once when the toast is removed by its timer or a swipe.
  internal var onDismiss: (() -> Void)?

  /// Creates a new toast with the specified content and behavior.
  ///
  /// - Parameters:
  ///   - icon: An optional view to display as an icon in the toast.
  ///   - message: The text content of the toast.
  ///   - detail: An optional second line shown under the message.
  ///   - button: An optional action button to display in the toast.
  ///   - duration: How long the toast should be displayed before automatically dismissing, in seconds. Clamped between 0 and 10 seconds. Default is 3.0.
  ///   - accessibilityMessage: What VoiceOver announces instead of the message and detail. Default is nil.
  ///   - key: Presenting a toast with the same non-nil key as a visible one updates that toast in place and
  ///     restarts its timer instead of adding another. The replaced value's `onDismiss` is kept unless the new
  ///     value has its own.
  ///   - onDismiss: Called once when the toast is removed by its timer or a swipe, not when it is replaced by key.
  public init(
    icon: (any View)? = nil,
    message: String,
    detail: String? = nil,
    button: ToastButton? = nil,
    duration: TimeInterval = 3.0,
    accessibilityMessage: String? = nil,
    key: AnyHashable? = nil,
    onDismiss: (() -> Void)? = nil
  ) {
    let clamped: TimeInterval? = min(max(0, duration), 10)
    self.init(
      icon: icon, message: message, detail: detail, button: button, duration: clamped,
      accessibilityMessage: accessibilityMessage, key: key, onDismiss: onDismiss
    )
  }
  @_disfavoredOverload
  internal init(
    icon: (any View)? = nil,
    message: String,
    detail: String? = nil,
    button: ToastButton? = nil,
    duration: TimeInterval? = nil,
    accessibilityMessage: String? = nil,
    key: AnyHashable? = nil,
    onDismiss: (() -> Void)? = nil
  ) {
    self.icon = icon.map { AnyView($0) }
    self.message = message
    self.detail = detail
    self.button = button
    self.duration = duration
    self.accessibilityMessage = accessibilityMessage
    self.key = key
    self.onDismiss = onDismiss
  }
}

/// Represents an action button that can be displayed within a toast.
public struct ToastButton {
  /// The text to display on the button.
  public var title: String

  /// The color of the button text.
  public var color: Color

  /// The action to perform when the button is tapped.
  public var action: () -> Void

  /// Creates a new toast button with the specified title, color, and action.
  ///
  /// - Parameters:
  ///   - title: The text to display on the button.
  ///   - color: The color of the button text. Default is `.primary`.
  ///   - action: The closure to execute when the button is tapped.
  public init(
    title: String,
    color: Color = .primary,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.color = color
    self.action = action
  }
}
