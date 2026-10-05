import SwiftUI

/// Optional overrides for how every toast looks. Anything left `nil` keeps the built-in 1.1.x look.
///
/// Set it once, outside `installToast`:
///
/// ```swift
/// ContentView()
///   .installToast(position: .top)
///   .toastStyle(ToastStyle(messageFont: .headline, background: .black))
/// ```
public struct ToastStyle: Equatable, Sendable {
  /// A shadow under the toast.
  public struct Shadow: Equatable, Sendable {
    public var color: Color
    public var radius: CGFloat
    public var x: CGFloat
    public var y: CGFloat

    public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
      self.color = color
      self.radius = radius
      self.x = x
      self.y = y
    }
  }

  /// Font of the message. Default: system 16 medium.
  public var messageFont: Font?
  /// Colour of the message. Default: `.primary`.
  public var messageColor: Color?
  /// Font of the optional second line (`ToastValue.detail`). Default: system 13 regular.
  public var detailFont: Font?
  /// Colour of the second line. Default: `.secondary`.
  public var detailColor: Color?
  /// Font of the button title. Default: the message font.
  public var buttonFont: Font?
  /// Background of the toast. Pass a dynamic colour to differ by colour scheme. Default: white in light
  /// mode, grey 0.12 in dark mode.
  public var background: Color?
  /// Background of the button. Default: the button's own colour at 7% (light) or 15% (dark).
  public var buttonBackground: Color?
  /// Corner radius of the toast. Default (`nil`): a capsule.
  public var cornerRadius: CGFloat?
  /// Shadow. Default: a faint one in light mode, none in dark mode.
  public var shadow: Shadow?
  /// Height of a single-line toast, and the minimum height of one with a detail line. Default: 48.
  public var height: CGFloat?
  /// Space above and below the text of a toast that has a detail line. Default: 8.
  public var detailVerticalPadding: CGFloat?
  /// Space between the toast and the safe area, on the edge it is positioned at. Default: 16.
  public var edgeSpacing: CGFloat?
  /// Letter spacing of the message. Default: none.
  public var messageTracking: CGFloat?
  /// Letter spacing of the button title. Default: none.
  public var buttonTracking: CGFloat?
  /// Space before the icon, or before the message when there is none. Default: 15 with an icon, 14 without.
  public var leadingPadding: CGFloat?
  /// Side of the square the icon is drawn in. Default: 19.
  public var iconSize: CGFloat?
  /// Space before the icon. Default: `leadingPadding`, else 15.
  public var iconLeadingPadding: CGFloat?
  /// Space after the message when there is no button. Default: 14.
  public var trailingPadding: CGFloat?
  /// Height of the button. Default (`nil`): it fills the toast less 10pt above and below.
  public var buttonHeight: CGFloat?
  /// Space either side of the button title. Default: 9.
  public var buttonHorizontalPadding: CGFloat?
  /// Narrowest the button may be; 0 lets it hug its title. Default: 64.
  public var buttonMinWidth: CGFloat?
  /// Extra space between the message and the button. Default: 0.
  public var buttonLeadingPadding: CGFloat?
  /// Space between the button and the toast's trailing edge. Default: 10.
  public var buttonTrailingPadding: CGFloat?

  public init(
    messageFont: Font? = nil,
    messageColor: Color? = nil,
    detailFont: Font? = nil,
    detailColor: Color? = nil,
    buttonFont: Font? = nil,
    background: Color? = nil,
    buttonBackground: Color? = nil,
    cornerRadius: CGFloat? = nil,
    shadow: Shadow? = nil,
    height: CGFloat? = nil,
    detailVerticalPadding: CGFloat? = nil,
    edgeSpacing: CGFloat? = nil,
    messageTracking: CGFloat? = nil,
    buttonTracking: CGFloat? = nil,
    leadingPadding: CGFloat? = nil,
    buttonHeight: CGFloat? = nil,
    buttonHorizontalPadding: CGFloat? = nil,
    buttonMinWidth: CGFloat? = nil,
    buttonLeadingPadding: CGFloat? = nil,
    buttonTrailingPadding: CGFloat? = nil,
    iconSize: CGFloat? = nil,
    iconLeadingPadding: CGFloat? = nil,
    trailingPadding: CGFloat? = nil
  ) {
    self.messageFont = messageFont
    self.messageColor = messageColor
    self.detailFont = detailFont
    self.detailColor = detailColor
    self.buttonFont = buttonFont
    self.background = background
    self.buttonBackground = buttonBackground
    self.cornerRadius = cornerRadius
    self.shadow = shadow
    self.height = height
    self.detailVerticalPadding = detailVerticalPadding
    self.edgeSpacing = edgeSpacing
    self.messageTracking = messageTracking
    self.buttonTracking = buttonTracking
    self.leadingPadding = leadingPadding
    self.buttonHeight = buttonHeight
    self.buttonHorizontalPadding = buttonHorizontalPadding
    self.buttonMinWidth = buttonMinWidth
    self.buttonLeadingPadding = buttonLeadingPadding
    self.buttonTrailingPadding = buttonTrailingPadding
    self.iconSize = iconSize
    self.iconLeadingPadding = iconLeadingPadding
    self.trailingPadding = trailingPadding
  }
}

extension EnvironmentValues {
  /// The style toasts are drawn with. Set it with `View.toastStyle(_:)`.
  public var toastStyle: ToastStyle {
    get { self[ToastStyleKey.self] }
    set { self[ToastStyleKey.self] = newValue }
  }
}

extension View {
  /// Styles the toasts of an `installToast` below this view in the hierarchy, so call it after `installToast`.
  public func toastStyle(_ style: ToastStyle) -> some View {
    environment(\.toastStyle, style)
  }
}

private enum ToastStyleKey: EnvironmentKey {
  static let defaultValue = ToastStyle()
}
