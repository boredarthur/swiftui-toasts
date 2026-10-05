import SwiftUI

internal struct ToastView: View {
  @ObservedObject var model: ToastModel
  var style = ToastStyle()
  @Environment(\.colorScheme) private var colorScheme

  private var isDark: Bool { colorScheme == .dark }
  private var height: CGFloat { style.height ?? 48 }

  var body: some View {
    sized(
      main
        ._background { backgroundShape }
    )
    .compositingGroup()
    .shadow(
      color: style.shadow?.color ?? .primary.opacity(isDark ? 0.0 : 0.1),
      radius: style.shadow?.radius ?? 16,
      x: style.shadow?.x ?? 0,
      y: style.shadow?.y ?? 8.0
    )
  }

  /// A single line keeps its fixed height; with a detail line the toast may grow past it.
  @ViewBuilder
  private func sized(_ content: some View) -> some View {
    if model.detail == nil {
      content.frame(height: height)
    } else {
      // The spacers beside the text would otherwise stretch to whatever height is offered.
      content.fixedSize(horizontal: false, vertical: true).frame(minHeight: height)
    }
  }

  @ViewBuilder
  private var backgroundShape: some View {
    let fill = style.background ?? Color.toastBackground
    if let radius = style.cornerRadius {
      RoundedRectangle(cornerRadius: radius, style: .continuous).fill(fill)
    } else {
      Capsule().fill(fill)
    }
  }

  private var main: some View {
    HStack(spacing: 10) {
      if let icon = model.icon {
        icon
          .frame(width: style.iconSize ?? 19, height: style.iconSize ?? 19)
          .padding(.leading, style.iconLeadingPadding ?? style.leadingPadding ?? 15)
      } else {
        Color.clear
          .frame(width: style.leadingPadding ?? 14)
      }
      text
      if let button = model.button {
        buttonView(button)
          .padding(.leading, style.buttonLeadingPadding ?? 0)
          .padding(.trailing, style.buttonTrailingPadding ?? 10)
          .padding(.vertical, style.buttonHeight == nil ? 10 : 0)
      } else {
        Color.clear
          .frame(width: style.trailingPadding ?? 14)
      }
    }
    .font(.system(size: 16, weight: .medium))
  }

  @ViewBuilder
  private var text: some View {
    if let detail = model.detail {
      VStack(alignment: .leading, spacing: 1) {
        messageText
        Text(detail)
          .font(style.detailFont ?? .system(size: 13))
          ._foregroundColor(style.detailColor ?? .secondary)
          .lineLimit(2)
      }
      .padding(.vertical, style.detailVerticalPadding ?? 8)
    } else {
      messageText
    }
  }

  private var messageText: some View {
    Text(model.message)
      .kerning(style.messageTracking ?? 0)
      .font(style.messageFont)
      ._foregroundColor(style.messageColor)
      .lineLimit(1)
      .truncationMode(.tail)
      .id(model.message)
      .transition(.asymmetric(
          insertion: .opacity
              .animation(.spring(duration: 0.3).delay(0.3)),
          removal: .opacity
              .animation(.spring(duration: 0.3))
      ))
  }

  private func buttonView(_ button: ToastButton) -> some View {
    Button {
      button.action()
    } label: {
      ZStack {
        Capsule()
          .fill(style.buttonBackground ?? button.color.opacity(isDark ? 0.15 : 0.07))
        Text(button.title)
          .kerning(style.buttonTracking ?? 0)
          .font(style.buttonFont)
          ._foregroundColor(button.color)
          .padding(.horizontal, style.buttonHorizontalPadding ?? 9)
      }
      .frame(minWidth: style.buttonMinWidth ?? 64)
      .frame(height: style.buttonHeight)
      .fixedSize(horizontal: true, vertical: false)
    }
    .buttonStyle(.plain)
  }
}

@available(iOS 17.0, *)
#Preview {
  let group = VStack {
    ToastView(
      model: .init(
        value:
          .init(
            icon: Image(systemName: "info.circle"),
            message: "This is a toast message",
            button: .init(title: "Action", color: .red, action: {})
          )
      )
    )
    ToastView(
      model: .init(
        value:
          .init(
            icon: Image(systemName: "info.circle"),
            message: "This is a toast message",
            button: .init(title: "Action", action: {})
          )
      )
    )
    ToastView(
      model: .init(
        value:
          .init(
            icon: Image(systemName: "info.circle"),
            message: "This is a toast message",
            button: nil
          )
      )
    )
    ToastView(
      model: .init(
        value:
          .init(
            icon: nil,
            message: "This is a toast message",
            button: nil
          )
      )
    )
    ToastView(
      model: .init(
        value:
          .init(
            icon: nil,
            message: "Copied",
            button: nil
          )
      )
    )
  }
  return VStack {
    group
    group
      .padding(20)
      .background {
        Color.black
      }
      .environment(\.colorScheme, .dark)
  }
}
